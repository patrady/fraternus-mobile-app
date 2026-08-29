-- Member and User Member Association — the core relational spine everything
-- else (Field Guide, Challenges, Events) hangs off of. Also defines the two
-- authorization helpers used across every user-generated table from here
-- on: has_member_association() and the COPPA write-gate
-- member_is_write_active().

create table public.members (
  id uuid primary key default gen_random_uuid(),
  chapter_key text not null references public.chapters (key) on delete restrict,
  role member_role not null,
  first_name text not null,
  last_name text not null,
  birthday date not null,
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
  -- Applicable only when relationship = 'guardian' and the Member is under
  -- 13 — see docs/app_concept.md's COPPA/Consent section.
  consent_status consent_status,
  consent_date timestamptz,
  consent_method text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, member_id),
  check (
    relationship = 'guardian'
    or (consent_status is null and consent_date is null and consent_method is null)
  )
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

-- COPPA enforcement: app_concept.md says a Brother under 13 with no
-- Granted guardian association is "inactive/pending everywhere... no data
-- entry accepted on their behalf" until consent is granted. Composed into
-- every write policy's `with check` on Member-scoped tables (Field Guide
-- Daily Devotional Member, Challenge Member, Event RSVP).
create or replace function public.member_is_write_active(target_member_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select
    m.role <> 'brother'
    or (extract(year from age(current_date, m.birthday))) >= 13
    or exists (
      select 1 from public.user_member_associations uma
      where uma.member_id = m.id
        and uma.relationship = 'guardian'
        and uma.consent_status = 'granted'
    )
  from public.members m
  where m.id = target_member_id;
$$;

revoke all on function public.member_is_write_active(uuid) from public;
grant execute on function public.member_is_write_active(uuid) to authenticated;

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

-- Lets a Guardian revoke (or otherwise edit) their own association rows
-- directly — e.g. flipping Consent Status to Revoked — without needing an
-- RPC for that one-field change. Restricted to relationship = 'guardian'
-- so a Self row (and its lack of consent fields) can't be repurposed.
create policy "guardian can update own guardian associations"
  on public.user_member_associations for update
  to authenticated
  using (user_id = auth.uid() and relationship = 'guardian')
  with check (user_id = auth.uid() and relationship = 'guardian');

-- No insert policy: only via create_child_member / complete_captain_signup.
-- No delete policy: cascades automatically from delete_member_data.

-- Base table-level grants — see the comment in the public_users migration
-- for why these are necessary in addition to the RLS policies above.
grant select, update on public.members to authenticated;
grant select, update on public.user_member_associations to authenticated;

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
