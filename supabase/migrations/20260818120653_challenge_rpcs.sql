-- Resolves the current challenge: app_concept.md — "A challenge that is
-- tied to the most recent past (non-cancelled) Frat Night remains in
-- effect until the next Frat Night takes place." Chapter-scoped via the
-- specific Frat Night Event instance (event_frat_night_details.chapter_key),
-- not the Frat Night Template itself, which isn't chapter-specific.
--
-- Capped at 21 days past the Frat Night: a chapter that hasn't met in a
-- while should show no current challenge rather than an arbitrarily stale
-- one.
create or replace function public.get_current_challenge(p_chapter_key text, p_as_of timestamptz default now())
returns uuid
language sql
stable
as $$
  select c.id
  from public.events e
  join public.event_frat_night_details efnd on efnd.event_id = e.id
  join public.challenges c on c.frat_night_template_key = efnd.frat_night_template_key
  where e.type = 'frat_night'
    and e.cancellation_date is null
    and efnd.chapter_key = p_chapter_key
    and e.start_date <= p_as_of
    and e.start_date >= p_as_of - interval '21 days'
  order by e.start_date desc
  limit 1;
$$;

grant execute on function public.get_current_challenge(text, timestamptz) to authenticated;

-- Insert/delete toggle (a rep row only exists once completed — no rep
-- number means incomplete) + recomputes challenge_members.completed_date.
-- Deliberately NOT security definer: unlike create_child_member or
-- get_all_event_eligible_members, everything this function touches is data
-- the caller already has an association for (has_challenge_member_association
-- confirms it), so running as the caller and relying on the table RLS
-- policies below is correct — defense in depth, not a workaround.
create or replace function public.toggle_challenge_rep(p_challenge_member_id uuid, p_rep_number int)
returns public.challenge_member_reps
language plpgsql
set search_path = public
as $$
declare
  v_reps_total int;
  v_existing public.challenge_member_reps;
  v_result public.challenge_member_reps;
  v_count int;
begin
  if not public.has_challenge_member_association(p_challenge_member_id) then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  select c.reps into v_reps_total
  from public.challenge_members cm
  join public.challenges c on c.id = cm.challenge_id
  where cm.id = p_challenge_member_id;

  select * into v_existing
  from public.challenge_member_reps
  where challenge_member_id = p_challenge_member_id and number = p_rep_number;

  if v_existing.id is not null then
    delete from public.challenge_member_reps where id = v_existing.id;
    v_result := null;
  else
    insert into public.challenge_member_reps (challenge_member_id, completed_by_user_id, number)
    values (p_challenge_member_id, auth.uid(), p_rep_number)
    returning * into v_result;
  end if;

  select count(*) into v_count
  from public.challenge_member_reps
  where challenge_member_id = p_challenge_member_id;

  update public.challenge_members
  set completed_date = case when v_count = v_reps_total then now()::date else null end
  where id = p_challenge_member_id;

  return v_result;
end;
$$;

grant execute on function public.toggle_challenge_rep(uuid, int) to authenticated;
