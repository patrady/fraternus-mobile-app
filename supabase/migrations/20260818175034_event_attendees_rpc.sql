-- "Others Attending": any authenticated user can see who else has accepted
-- (RSVP'd "Going" to) an event, whether or not they've RSVP'd themselves —
-- independent of event_rsvps' own RLS, which restricts direct reads to the
-- caller's own household. security definer + a narrow returned shape (just
-- the name) is the same pattern as get_event_eligible_members: a
-- cross-household read gets its own RPC rather than a blanket RLS policy
-- that would also require loosening `members`' own RLS to make the nested
-- embed's name lookup work.
--
-- Excludes the caller's own household — those members are already shown
-- via the RSVP section, not "Others Attending". Ordered alphabetically so
-- the list reads predictably to a Captain scanning it, rather than
-- whatever order Postgres happens to return the join in.
-- is_hawc and officer_roles let the client show an officer-role badge
-- (see supabase/migrations/20260818175033_officer_roles.sql) on attendees
-- outside the caller's own household, the same way it already can for
-- household members via the members(*, member_officer_roles(...)) embed —
-- officer_roles is pre-sorted by priority here so the client can just take
-- the first entry without needing to know the priority ordering itself.
create or replace function public.get_event_attendees(p_event_id uuid)
returns table (
  member_id uuid,
  first_name text,
  last_name text,
  is_hawc boolean,
  officer_roles jsonb
)
language sql
stable
security definer
set search_path = public
as $$
  select
    m.id,
    m.first_name,
    m.last_name,
    m.is_hawc,
    coalesce(orl.officer_roles, '[]'::jsonb)
  from public.event_rsvps er
  join public.members m on m.id = er.member_id
  left join lateral (
    select jsonb_agg(
      jsonb_build_object('key', ro.key, 'label', ro.label, 'priority', ro.priority)
      order by ro.priority
    ) as officer_roles
    from public.member_officer_roles mor
    join public.officer_roles ro on ro.key = mor.officer_role_key
    where mor.member_id = m.id
  ) orl on true
  where er.event_id = p_event_id
    and er.response = 'accepted'
    and not public.has_member_association(er.member_id)
  order by m.last_name, m.first_name;
$$;

revoke all on function public.get_event_attendees(uuid) from public;
grant execute on function public.get_event_attendees(uuid) to authenticated;
