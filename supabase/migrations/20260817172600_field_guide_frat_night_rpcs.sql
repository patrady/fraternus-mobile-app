-- Resolves Field Guide content off the chapter's Frat Night events, same
-- anchor Challenges use (see get_current_challenge in
-- 20260818120653_challenge_rpcs.sql): a Frat Night Template's Field Guide
-- Week runs for the 7 days starting on whichever Event references that
-- template. Day 1 is literally that Event's start_date — no separate
-- school-year/offset configuration (the now-removed
-- chapter_field_guide_details table) needed.
--
-- Placed after the events migration (not alongside the rest of Phase 3's
-- RPCs in 20260815171935_rpc_functions.sql) since it depends on
-- public.events/event_frat_night_details, which don't exist until then.

-- Resolves which devotional applies to a given chapter/date. Single source
-- of truth — shared by the Guide screen and the Today dashboard, so the
-- algorithm is never duplicated client-side.
--
-- Finds the single most recent past (non-cancelled) Frat Night event for
-- the chapter *first*, independent of whether it has Field Guide content —
-- deliberately not an inner join straight to a matching daily devotional,
-- which would incorrectly skip past a content-less Frat Night (e.g. a Rush
-- Night) and resolve to an older week's stale content instead.
create or replace function public.get_field_guide_devotional_for_date(
  p_chapter_key text,
  p_date date
) returns table (daily_devotional_id uuid, field_guide_week_id uuid)
language sql
stable
as $$
  with current_frat_night as (
    select e.start_date::date as start_date, fnt.field_guide_week_id
    from public.events e
    join public.event_frat_night_details efnd on efnd.event_id = e.id
    join public.frat_night_templates fnt on fnt.key = efnd.frat_night_template_key
    where e.type = 'frat_night'
      and e.cancellation_date is null
      and efnd.chapter_key = p_chapter_key
      and e.start_date::date <= p_date
    order by e.start_date desc
    limit 1
  )
  select fgd.id, cfn.field_guide_week_id
  from current_frat_night cfn
  join public.field_guide_daily_devotionals fgd on fgd.field_guide_week_id = cfn.field_guide_week_id
  where cfn.field_guide_week_id is not null
    and (p_date - cfn.start_date) between 0 and 6
    and fgd.day_number = (p_date - cfn.start_date) + 1
  limit 1;
$$;

grant execute on function public.get_field_guide_devotional_for_date(text, date) to authenticated;

-- Consecutive completed days for p_member_id ending the day *before*
-- p_as_of (deliberately excludes p_as_of itself — see
-- GuideRepository.fetchStreak's doc comment: the client adds +1 live the
-- moment today's row is marked complete, without a round trip).
--
-- Resets naturally whenever there's a gap with no authored content to
-- complete (e.g. summer break between school years, or a stretch of Rush
-- Nights with no Field Guide Week) — no separate school-year boundary
-- needed, since the generic streak rule (a missed day breaks the streak)
-- already covers it once there's nothing to author days from.
create or replace function public.get_field_guide_streak(
  p_member_id uuid,
  p_chapter_key text,
  p_as_of date
) returns integer
language sql
stable
as $$
  with chapter_frat_nights as (
    select
      e.start_date::date as start_date,
      fnt.field_guide_week_id,
      lead(e.start_date::date) over (order by e.start_date) as next_start_date
    from public.events e
    join public.event_frat_night_details efnd on efnd.event_id = e.id
    join public.frat_night_templates fnt on fnt.key = efnd.frat_night_template_key
    where e.type = 'frat_night'
      and e.cancellation_date is null
      and efnd.chapter_key = p_chapter_key
  ),
  candidate_days as (
    select
      d::date as day,
      (d::date - cfn.start_date) as days_since_start,
      cfn.field_guide_week_id
    from chapter_frat_nights cfn,
      generate_series(
        cfn.start_date,
        least(cfn.start_date + 6, coalesce(cfn.next_start_date, p_as_of) - 1, p_as_of - 1),
        interval '1 day'
      ) as d
    where cfn.field_guide_week_id is not null
  ),
  authored_days as (
    select cd.day, fgd.id as daily_devotional_id
    from candidate_days cd
    join public.field_guide_daily_devotionals fgd
      on fgd.field_guide_week_id = cd.field_guide_week_id
     and fgd.day_number = cd.days_since_start + 1
  ),
  completion_flagged as (
    select
      (fgdm.completed_date is not null) as is_completed,
      row_number() over (order by ad.day desc) as rn
    from authored_days ad
    left join public.field_guide_daily_devotional_members fgdm
      on fgdm.daily_devotional_id = ad.daily_devotional_id
     and fgdm.member_id = p_member_id
  ),
  first_gap as (
    select min(rn) as gap_rn from completion_flagged where not is_completed
  )
  select coalesce(
    (select count(*)::integer from completion_flagged
     where rn < coalesce((select gap_rn from first_gap), 2147483647)),
    0
  );
$$;

grant execute on function public.get_field_guide_streak(uuid, text, date) to authenticated;
