-- Custom RPC endpoints for Phase 3 (the Field Guide CRUD slice) plus the
-- two signup-completion functions every signup path depends on. See the
-- implementation plan §4 for the full endpoint catalog and rationale —
-- default to plain PostgREST for straightforward reads, RPC only for real
-- logic (date-math, atomicity, server-side validation).

-- 1. Resolves which devotional applies to a given chapter/date via the
-- school-year/week/day algorithm in docs/app_concept.md. Single source of
-- truth — shared by the Guide screen and (later) the Today dashboard, so
-- the algorithm is never duplicated client-side.
create or replace function public.get_field_guide_devotional_for_date(
  p_chapter_id uuid,
  p_date date
) returns table (daily_devotional_id uuid, field_guide_week_id uuid)
language sql
stable
as $$
  with details as (
    select *
    from public.chapter_field_guide_details
    where chapter_id = p_chapter_id
      and p_date between school_year_start_date and school_year_end_date
    order by field_guide_start_date desc
    limit 1
  ),
  offset_calc as (
    select (p_date - field_guide_start_date) as days_since_start
    from details
  )
  select fgd.id, fgw.id
  from public.field_guide_daily_devotionals fgd
  join public.field_guide_weeks fgw on fgw.id = fgd.field_guide_week_id
  cross join offset_calc
  where offset_calc.days_since_start >= 0
    and fgw.week_number = offset_calc.days_since_start / 7
    -- +1: matches the shipped Dart convention (day_number 1-7, Monday-
    -- anchored, matching DateTime.weekday) rather than app_concept.md's
    -- literal "mod 7" prose (implying 0-6) — see the plan's decision note.
    and fgd.day_number = (offset_calc.days_since_start % 7) + 1
  limit 1;
$$;

grant execute on function public.get_field_guide_devotional_for_date(uuid, date) to authenticated;

-- 2. Consecutive completed days for p_member_id ending the day *before*
-- p_as_of (deliberately excludes p_as_of itself — see
-- GuideRepository.fetchStreak's doc comment: the client adds +1 live the
-- moment today's row is marked complete, without a round trip). Resets at
-- the start of each new school year since streak-eligible days never
-- extend past the current chapter_field_guide_details.field_guide_start_date.
create or replace function public.get_field_guide_streak(
  p_member_id uuid,
  p_chapter_id uuid,
  p_as_of date
) returns integer
language sql
stable
as $$
  with details as (
    select *
    from public.chapter_field_guide_details
    where chapter_id = p_chapter_id
      and p_as_of between school_year_start_date and school_year_end_date
    order by field_guide_start_date desc
    limit 1
  ),
  candidate_days as (
    select
      d::date as day,
      (d::date - details.field_guide_start_date) as days_since_start
    from details, generate_series(details.field_guide_start_date, p_as_of - 1, interval '1 day') as d
  ),
  authored_days as (
    select ad.day, fgd.id as daily_devotional_id
    from candidate_days ad
    join public.field_guide_weeks fgw on fgw.week_number = ad.days_since_start / 7
    join public.field_guide_daily_devotionals fgd
      on fgd.field_guide_week_id = fgw.id
     and fgd.day_number = (ad.days_since_start % 7) + 1
    where ad.days_since_start >= 0
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

grant execute on function public.get_field_guide_streak(uuid, uuid, date) to authenticated;

-- 9. Atomically creates a Brother Member + Guardian association (+ Pending
-- consent if under 13), for the currently-authenticated Guardian. Replaces
-- the client doing a two-step Member-then-Association write, which would
-- otherwise need its own transaction handling on the client side.
create or replace function public.create_child_member(
  p_first_name text,
  p_last_name text,
  p_chapter_id uuid,
  p_birthday date,
  p_email text default null
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_member_id uuid;
  v_requires_consent boolean;
begin
  insert into public.members (chapter_id, role, first_name, last_name, birthday, email)
  values (p_chapter_id, 'brother', p_first_name, p_last_name, p_birthday, p_email)
  returning id into v_member_id;

  v_requires_consent := extract(year from age(current_date, p_birthday)) < 13;

  insert into public.user_member_associations (user_id, member_id, relationship, consent_status)
  values (
    auth.uid(),
    v_member_id,
    'guardian',
    case when v_requires_consent then 'pending'::consent_status else null end
  );

  return v_member_id;
end;
$$;

revoke all on function public.create_child_member(text, text, uuid, date, text) from public;
grant execute on function public.create_child_member(text, text, uuid, date, text) to authenticated;

-- 10. Atomically creates a Captain Member + Self association for the
-- currently-authenticated user. Used by both signup branches that create a
-- Captain-role Member for themselves — a Captain signing up directly, and
-- a Guardian who also attends meetings (see app_concept.md's Profile
-- section; nothing about this RPC is Captain-signup-specific beyond name).
create or replace function public.complete_captain_signup(
  p_chapter_id uuid,
  p_first_name text,
  p_last_name text,
  p_birthday date
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_member_id uuid;
begin
  insert into public.members (chapter_id, role, first_name, last_name, birthday, email)
  select p_chapter_id, 'captain', p_first_name, p_last_name, p_birthday, u.email
  from public.users u
  where u.id = auth.uid()
  returning id into v_member_id;

  insert into public.user_member_associations (user_id, member_id, relationship)
  values (auth.uid(), v_member_id, 'self');

  return v_member_id;
end;
$$;

revoke all on function public.complete_captain_signup(uuid, text, text, date) from public;
grant execute on function public.complete_captain_signup(uuid, text, text, date) to authenticated;
