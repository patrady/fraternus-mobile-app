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
create or replace function public.get_event_attendees(p_event_id uuid)
returns table (member_id uuid, first_name text, last_name text)
language sql
stable
security definer
set search_path = public
as $$
  select m.id, m.first_name, m.last_name
  from public.event_rsvps er
  join public.members m on m.id = er.member_id
  where er.event_id = p_event_id
    and er.response = 'accepted'
    and not public.has_member_association(er.member_id)
  order by m.last_name, m.first_name;
$$;

revoke all on function public.get_event_attendees(uuid) from public;
grant execute on function public.get_event_attendees(uuid) to authenticated;
