-- Phase 7 (Events feature): the client-facing RSVP submission RPC, plus the
-- delete policy it needs, and the caller-scoped eligibility lookup that
-- feeds RSVP row/UI rendering. See the comment left in the events
-- migration for why these weren't added speculatively back then.

-- toggle-off support for submit_event_rsvp below — without this, its own
-- DELETE would be blocked exactly like a raw client DELETE would be, same
-- reasoning as challenge_member_reps' delete policy.
create policy "delete own household rsvps"
  on public.event_rsvps for delete
  to authenticated
  using (public.has_member_association(member_id));

grant delete on public.event_rsvps to authenticated;

-- Caller-household-scoped counterpart to get_all_event_eligible_members
-- (which is service_role-only and chapter-wide). Takes the caller's own
-- member ids rather than resolving them server-side, and re-checks
-- has_member_association on each as defense in depth — a caller passing a
-- member id they have no association with simply gets it filtered out,
-- not an error, since this is a read-model helper, not a write gate.
create or replace function public.get_event_eligible_members(p_event_id uuid, p_member_ids uuid[])
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
  where m.id = any(p_member_ids)
    and public.has_member_association(m.id)
    and (
      eac.role = 'chapter'
      or (eac.role = 'captains' and m.role in ('captain', 'commander'))
      or (eac.role = 'brothers' and m.role = 'brother')
    )
  union
  select member_id
  from public.event_attendees_specific
  where event_id = p_event_id
    and member_id = any(p_member_ids)
    and public.has_member_association(member_id);
$$;

revoke all on function public.get_event_eligible_members(uuid, uuid[]) from public;
grant execute on function public.get_event_eligible_members(uuid, uuid[]) to authenticated;

-- Upsert-or-delete-if-reselecting-same-value toggle, matching
-- toggle_challenge_rep's shape — "unanswered" means no row at all (see
-- HouseholdRsvp's doc comment), so re-tapping the currently-selected
-- option must delete the row, not just overwrite it with itself.
--
-- Deliberately NOT security definer, same reasoning as toggle_challenge_rep:
-- has_member_association already confirms the caller owns this member, so
-- running as the caller and relying on event_rsvps' own RLS policies above
-- is correct — defense in depth, not a workaround.
create or replace function public.submit_event_rsvp(p_event_id uuid, p_member_id uuid, p_response rsvp_response)
returns public.event_rsvps
language plpgsql
set search_path = public
as $$
declare
  v_existing public.event_rsvps;
  v_result public.event_rsvps;
begin
  if not public.has_member_association(p_member_id) then
    raise exception 'not authorized to rsvp for this member' using errcode = '42501';
  end if;

  select * into v_existing
  from public.event_rsvps
  where event_id = p_event_id and member_id = p_member_id;

  if v_existing.id is not null and v_existing.response = p_response then
    delete from public.event_rsvps where id = v_existing.id;
    return null;
  end if;

  insert into public.event_rsvps (event_id, member_id, response)
  values (p_event_id, p_member_id, p_response)
  on conflict (event_id, member_id)
  do update set response = excluded.response, submitted_by_user_id = auth.uid()
  returning * into v_result;

  return v_result;
end;
$$;

grant execute on function public.submit_event_rsvp(uuid, uuid, rsvp_response) to authenticated;
