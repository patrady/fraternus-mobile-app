-- Kings Messenger: a Captain can sign up to give the "Kings Message" — a
-- short reflection on the video clip — for a specific Frat Night. Hangs off
-- event_frat_night_details rather than events directly, since this is
-- intrinsically Frat-Night-specific (mirrors why officer_roles/challenges
-- key off frat_night_templates rather than events). Multiple rows per Frat
-- Night are allowed by the schema (rare, hand-managed beyond the first) —
-- see docs/app_concept.md.
--
-- No updated_at/trigger: like member_officer_roles and
-- event_attendees_specific, this is a pure signup row with no mutable
-- columns, so created_at alone is sufficient.

create table public.event_frat_night_kings_messengers (
  id uuid primary key default gen_random_uuid(),
  event_frat_night_details_id uuid not null references public.event_frat_night_details (id) on delete cascade,
  member_id uuid not null references public.members (id) on delete cascade,
  submitted_by_user_id uuid references public.users (id) on delete set null,
  created_at timestamptz not null default now(),
  constraint event_frat_night_kings_messengers_unique unique (event_frat_night_details_id, member_id)
);

create index idx_event_frat_night_kings_messengers_details_id
  on public.event_frat_night_kings_messengers (event_frat_night_details_id);

create trigger set_event_frat_night_kings_messengers_submitted_by_user_id
  before insert on public.event_frat_night_kings_messengers
  for each row
  execute function public.set_submitted_by_user_id();

alter table public.event_frat_night_kings_messengers enable row level security;

-- Open read: who's giving the Kings Message is meant to be visible to the
-- whole chapter, not just the signed-up Captain's own household — same
-- reasoning as event_attendees_chapter/event_frat_night_details. Resolving
-- a messenger's name still requires the get_event_kings_messengers RPC
-- below, since a plain nested embed of `members` would hit that table's own
-- household-scoped RLS for anyone outside the caller's household.
create policy "select kings messengers"
  on public.event_frat_night_kings_messengers for select
  to authenticated
  using (true);

create policy "insert own kings messenger signup"
  on public.event_frat_night_kings_messengers for insert
  to authenticated
  with check (public.has_member_association(member_id));

create policy "delete own kings messenger signup"
  on public.event_frat_night_kings_messengers for delete
  to authenticated
  using (public.has_member_association(member_id));

grant select, insert, delete on public.event_frat_night_kings_messengers to authenticated;

-- Client-facing toggle, mirroring submit_event_rsvp's shape: deliberately
-- NOT security definer — has_member_association already confirms the
-- caller owns this member, so running as the caller and relying on the RLS
-- policies above is correct (defense in depth, not a workaround). Also
-- checks the target member's role, since has_member_association alone
-- would let a Guardian pass their Brother child's member id (Guardian is a
-- valid association for a Brother) — only Captains can be Kings Messengers.
create or replace function public.submit_kings_messenger_signup(p_event_frat_night_details_id uuid, p_member_id uuid)
returns public.event_frat_night_kings_messengers
language plpgsql
set search_path = public
as $$
declare
  v_member_role member_role;
  v_existing public.event_frat_night_kings_messengers;
  v_result public.event_frat_night_kings_messengers;
begin
  if not public.has_member_association(p_member_id) then
    raise exception 'not authorized to sign up for this member' using errcode = '42501';
  end if;

  select role into v_member_role from public.members where id = p_member_id;
  if v_member_role is distinct from 'captain' then
    raise exception 'only captains can sign up as kings messenger' using errcode = '42501';
  end if;

  select * into v_existing
  from public.event_frat_night_kings_messengers
  where event_frat_night_details_id = p_event_frat_night_details_id and member_id = p_member_id;

  if v_existing.id is not null then
    delete from public.event_frat_night_kings_messengers where id = v_existing.id;
    return null;
  end if;

  insert into public.event_frat_night_kings_messengers (event_frat_night_details_id, member_id)
  values (p_event_frat_night_details_id, p_member_id)
  returning * into v_result;

  return v_result;
end;
$$;

grant execute on function public.submit_kings_messenger_signup(uuid, uuid) to authenticated;

-- Cross-household name resolution, mirroring get_event_attendees — needed
-- because the open select policy above only covers the junction table
-- itself; resolving first/last name still hits members' own household-
-- scoped RLS for anyone outside the caller's household without this.
create or replace function public.get_event_kings_messengers(p_event_frat_night_details_id uuid)
returns table (
  member_id uuid,
  first_name text,
  last_name text
)
language sql
stable
security definer
set search_path = public
as $$
  select m.id, m.first_name, m.last_name
  from public.event_frat_night_kings_messengers ekm
  join public.members m on m.id = ekm.member_id
  where ekm.event_frat_night_details_id = p_event_frat_night_details_id
  order by ekm.created_at;
$$;

revoke all on function public.get_event_kings_messengers(uuid) from public;
grant execute on function public.get_event_kings_messengers(uuid) to authenticated;
