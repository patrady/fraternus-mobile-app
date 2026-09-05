-- Member and User Member Association — the core relational spine everything
-- else (Field Guide, Challenges, Events) hangs off of. Also defines
-- has_member_association(), the authorization helper used across every
-- user-generated table from here on.

create table public.members (
  id uuid primary key default gen_random_uuid(),
  chapter_key text not null references public.chapters (key) on delete restrict,
  role member_role not null,
  first_name text not null,
  last_name text not null,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger set_members_updated_at
  before update on public.members
  for each row
  execute function public.set_updated_at();

create index idx_members_chapter_key on public.members (chapter_key);

create table public.user_member_associations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users (id) on delete cascade,
  member_id uuid not null references public.members (id) on delete cascade,
  relationship association_relationship not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, member_id)
);

create trigger set_user_member_associations_updated_at
  before update on public.user_member_associations
  for each row
  execute function public.set_updated_at();

create index idx_user_member_associations_user_id on public.user_member_associations (user_id);
create index idx_user_member_associations_member_id on public.user_member_associations (member_id);

-- Authorization helpers ------------------------------------------------

-- True if the calling user (auth.uid()) has a Self or Guardian association
-- with target_member_id. security definer so it can read
-- user_member_associations regardless of that table's own RLS policies —
-- every write/read policy on a Member-scoped table composes this in.
create or replace function public.has_member_association(target_member_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.user_member_associations
    where member_id = target_member_id and user_id = auth.uid()
  );
$$;

revoke all on function public.has_member_association(uuid) from public;
grant execute on function public.has_member_association(uuid) to authenticated;

-- RLS --------------------------------------------------------------------

alter table public.members enable row level security;

create policy "select own household members"
  on public.members for select
  to authenticated
  using (public.has_member_association(id));

create policy "update own household members"
  on public.members for update
  to authenticated
  using (public.has_member_association(id))
  with check (public.has_member_association(id));

-- No insert policy: rows are created only via the create_child_member /
-- complete_captain_signup RPCs (see rpc_functions migration), both
-- security definer.
-- No delete policy: only via the delete_member_data RPC
-- (docs/adrs/003_coppa_child_data_deletion.md).

alter table public.user_member_associations enable row level security;

create policy "select own associations"
  on public.user_member_associations for select
  to authenticated
  using (user_id = auth.uid());

-- No update policy: association rows have no Guardian-editable fields.
-- No insert policy: only via create_child_member / complete_captain_signup.
-- No delete policy: cascades automatically from delete_member_data.

-- Base table-level grants — see the comment in the public_users migration
-- for why these are necessary in addition to the RLS policies above.
grant select, update on public.members to authenticated;
grant select on public.user_member_associations to authenticated;

-- service_role's BYPASSRLS attribute skips RLS policy checks, but it is
-- NOT a substitute for a table grant — confirmed against the real local
-- stack: service_role had the same bare TRUNCATE/REFERENCES/TRIGGER/
-- MAINTAIN default as authenticated, and a direct service_role query
-- against user_member_associations failed with "permission denied" until
-- this grant was added. Only tables a service_role caller queries
-- *directly* (not through a security definer function, which runs as the
-- function's owner regardless of caller) need this — the
-- notify-event-cancellation Edge Function queries this table directly to
-- resolve which Users to notify.
grant select on public.user_member_associations to service_role;
