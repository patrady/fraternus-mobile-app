-- Resolves every Member eligible for an event, regardless of household —
-- used exclusively by the event-cancellation Edge Function (service_role)
-- to know who to notify, independent of RSVP status per app_concept.md
-- ("If an event is cancelled, a notification is sent to all eligible
-- attendees whether they RSVPd or not").
--
-- Deliberately NOT granted to `authenticated`: an unscoped "every eligible
-- member across every household" result is real household-composition
-- information that a client has no business enumerating. The client-facing,
-- caller-household-scoped version of this query (taking a p_member_ids
-- array) belongs to Phase 7's SupabaseEventsRepository, not built yet since
-- nothing calls it before then — this function is intentionally the only
-- one of the two that exists right now.
create or replace function public.get_all_event_eligible_members(p_event_id uuid)
returns table (member_id uuid)
language sql
stable
security definer
set search_path = public
as $$
  select m.id
  from public.members m
  join public.event_attendees_chapter eac
    on eac.event_id = p_event_id and eac.chapter_id = m.chapter_id
  where eac.role = 'chapter'
     or (eac.role = 'captains' and m.role in ('captain', 'commander'))
     or (eac.role = 'brothers' and m.role = 'brother')
  union
  select member_id
  from public.event_attendees_specific
  where event_id = p_event_id;
$$;

revoke all on function public.get_all_event_eligible_members(uuid) from public;
grant execute on function public.get_all_event_eligible_members(uuid) to service_role;
