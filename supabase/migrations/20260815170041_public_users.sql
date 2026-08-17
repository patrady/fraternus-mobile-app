-- public.users mirrors the subset of auth.users this app needs, since
-- auth.users itself is not queryable via PostgREST. Populated by a trigger
-- on auth.users insert, capturing first/last name from signUp() metadata.
-- Every FK and RLS policy in the rest of this schema points at this table,
-- not at auth.users directly.

create table public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  first_name text not null default '',
  last_name text not null default '',
  email text not null,
  is_reminders_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger set_users_updated_at
  before update on public.users
  for each row
  execute function public.set_updated_at();

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, first_name, last_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'first_name', ''),
    coalesce(new.raw_user_meta_data ->> 'last_name', ''),
    new.email
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_auth_user();

-- RLS is enabled in the same migration that creates the table, not deferred
-- to a later "policies" migration, so a table is never left ungoverned even
-- transiently.
alter table public.users enable row level security;

create policy "select own user row"
  on public.users for select
  to authenticated
  using (auth.uid() = id);

create policy "update own user row"
  on public.users for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- No insert policy: rows are created only by handle_new_auth_user(), which
-- is security definer and bypasses RLS.
-- No delete policy: user-account deletion is out of scope for this plan.

-- RLS restricts *which rows* are visible/writable, but Postgres's own base
-- GRANT system decides whether the role can touch the table at all in the
-- first place — Supabase's local/hosted Postgres does NOT grant SELECT/
-- INSERT/UPDATE/DELETE to anon/authenticated by default (verified against
-- a real local stack: `\dp` showed authenticated only had TRUNCATE/
-- REFERENCES/TRIGGER/MAINTAIN out of the box). Every table needs an
-- explicit grant matching whatever its RLS policies allow — RLS alone is
-- not sufficient, contrary to the assumption in earlier revisions of these
-- migrations.
grant select, update on public.users to authenticated;
