-- Database Webhook for event cancellation: fires the
-- notify-event-cancellation Edge Function the moment cancellation_date
-- transitions from null to non-null. A custom trigger function (rather
-- than the generic supabase_functions.http_request helper) is used so the
-- shared webhook secret can be looked up at invocation time via Vault
-- instead of being a literal baked into this migration file — the actual
-- secret value must never be committed to git.
--
-- (`alter database ... set app.settings.x` was the first approach tried
-- here, but even the local `postgres` role isn't a true superuser on
-- Supabase's Postgres image and can't set arbitrary custom GUCs that way —
-- confirmed against the real local stack. Vault is the mechanism Supabase
-- actually supports for this.)
--
-- One-time manual setup this migration deliberately does NOT do (secrets
-- don't belong in migration files) — run once per environment (local and,
-- separately, hosted) against that environment's DB_URL:
--   select vault.create_secret('<a-random-string>', 'webhook_secret');
-- Then `supabase secrets set WEBHOOK_SECRET='<the same random string>'` so
-- notify-event-cancellation can verify the header matches.

create schema if not exists private;

-- Not a secret (just an environment-specific URL) so it doesn't need
-- Vault — but it does need to differ between local and hosted, so it's
-- config, not a migration-time literal. Never exposed via PostgREST: this
-- schema isn't in config.toml's [api] schemas list, and no grants are
-- given to anon/authenticated regardless.
create table private.app_config (
  key text primary key,
  value text not null
);

revoke all on private.app_config from anon, authenticated;

insert into private.app_config (key, value)
values ('edge_functions_url', 'http://127.0.0.1:54321/functions/v1')
on conflict (key) do nothing;

create or replace function public.notify_event_cancellation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  webhook_secret text;
  function_url text;
begin
  select decrypted_secret into webhook_secret
  from vault.decrypted_secrets
  where name = 'webhook_secret'
  limit 1;

  select value into function_url from private.app_config where key = 'edge_functions_url';

  if webhook_secret is null or function_url is null then
    -- Not configured yet (e.g. a fresh checkout before the one-time Vault
    -- setup above) — skip rather than fail the UPDATE that cancelled the
    -- event. Losing a push notification is recoverable; losing the
    -- ability to cancel an event is not.
    return new;
  end if;

  perform net.http_post(
    url := function_url || '/notify-event-cancellation',
    headers := jsonb_build_object('Content-Type', 'application/json', 'X-Webhook-Secret', webhook_secret),
    body := jsonb_build_object(
      'type', 'UPDATE',
      'table', 'events',
      'schema', 'public',
      'record', to_jsonb(new),
      'old_record', to_jsonb(old)
    ),
    timeout_milliseconds := 5000
  );

  return new;
end;
$$;

create trigger on_event_cancelled
  after update on public.events
  for each row
  when (old.cancellation_date is null and new.cancellation_date is not null)
  execute function public.notify_event_cancellation();
