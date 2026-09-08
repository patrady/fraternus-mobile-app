-- App version lockout: lets us force-update devices on a bad release
-- without waiting on an expedited store review. Two independent knobs, both
-- populated by hand via Studio/SQL since there's no admin UI yet:
--   - app_minimum_versions: a per-platform floor — anything strictly below
--     it is blocked.
--   - app_deprecated_versions: a one-off denylist for a specific bad
--     release, independent of the floor.
--
-- Both tables stay locked down (RLS enabled, no policies/grants for
-- anon/authenticated) — clients never query them directly, only through
-- get_app_version_status below, which normalizes both checks into a single
-- {blocked, reason, message} result instead of exposing the raw
-- deprecation history. The function must live in `public` (not `private`,
-- see the event_cancellation_webhook migration) since PostgREST only
-- exposes functions from schemas listed in config.toml's [api] schemas,
-- and this one has to be callable pre-login.

create type app_platform as enum ('ios', 'android');

create table public.app_minimum_versions (
  platform app_platform primary key,
  -- Plain major.minor.patch integers, matching pubspec.yaml's version
  -- convention (no pre-release suffixes) — e.g. '1.3.0'.
  minimum_version text not null,
  message text,
  updated_at timestamptz not null default now()
);

create trigger set_app_minimum_versions_updated_at
  before update on public.app_minimum_versions
  for each row
  execute function public.set_updated_at();

create table public.app_deprecated_versions (
  id uuid primary key default gen_random_uuid(),
  platform app_platform not null,
  version text not null,
  message text,
  created_at timestamptz not null default now(),
  unique (platform, version)
);

alter table public.app_minimum_versions enable row level security;
alter table public.app_deprecated_versions enable row level security;

-- security definer so the function can read the two locked-down tables
-- above regardless of the calling role (anon included) — it's owned by the
-- migration-running role, which owns both tables and is therefore exempt
-- from their RLS, same as any other Supabase-managed table.
create or replace function public.get_app_version_status(p_platform app_platform, p_version text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, pg_temp
as $$
declare
  v_deprecated record;
  v_minimum record;
begin
  select version, message into v_deprecated
  from public.app_deprecated_versions
  where platform = p_platform and version = p_version;

  if found then
    return jsonb_build_object('blocked', true, 'reason', 'deprecated', 'message', v_deprecated.message);
  end if;

  select minimum_version, message into v_minimum
  from public.app_minimum_versions
  where platform = p_platform;

  -- Postgres arrays compare lexicographically, which gives correct
  -- semver-style ordering for plain major.minor.patch integers for free.
  if found and string_to_array(p_version, '.')::int[] < string_to_array(v_minimum.minimum_version, '.')::int[] then
    return jsonb_build_object('blocked', true, 'reason', 'below_minimum', 'message', v_minimum.message);
  end if;

  return jsonb_build_object('blocked', false);
end;
$$;

grant execute on function public.get_app_version_status(app_platform, text) to anon, authenticated;
