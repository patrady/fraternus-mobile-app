-- p_chapter_key params now take chapters.key (text), not chapters.id (uuid)
-- — CREATE OR REPLACE can't change a parameter's type, so each function is
-- dropped and recreated with the same body.

drop function public.get_field_guide_devotional_for_date(uuid, date);

create function public.get_field_guide_devotional_for_date(
  p_chapter_key text,
  p_date date
) returns table (daily_devotional_id uuid, field_guide_week_id uuid)
language sql
stable
as $$
  with details as (
    select *
    from public.chapter_field_guide_details
    where chapter_key = p_chapter_key
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
    and fgd.day_number = (offset_calc.days_since_start % 7) + 1
  limit 1;
$$;

grant execute on function public.get_field_guide_devotional_for_date(text, date) to authenticated;

drop function public.get_field_guide_streak(uuid, uuid, date);

create function public.get_field_guide_streak(
  p_member_id uuid,
  p_chapter_key text,
  p_as_of date
) returns integer
language sql
stable
as $$
  with details as (
    select *
    from public.chapter_field_guide_details
    where chapter_key = p_chapter_key
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

grant execute on function public.get_field_guide_streak(uuid, text, date) to authenticated;

drop function public.create_child_member(text, text, uuid, date, text);

create function public.create_child_member(
  p_first_name text,
  p_last_name text,
  p_chapter_key text,
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
  insert into public.members (chapter_key, role, first_name, last_name, birthday, email)
  values (p_chapter_key, 'brother', p_first_name, p_last_name, p_birthday, p_email)
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

revoke all on function public.create_child_member(text, text, text, date, text) from public;
grant execute on function public.create_child_member(text, text, text, date, text) to authenticated;

drop function public.complete_captain_signup(uuid, text, text, date);

create function public.complete_captain_signup(
  p_chapter_key text,
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
  insert into public.members (chapter_key, role, first_name, last_name, birthday, email)
  select p_chapter_key, 'captain', p_first_name, p_last_name, p_birthday, u.email
  from public.users u
  where u.id = auth.uid()
  returning id into v_member_id;

  insert into public.user_member_associations (user_id, member_id, relationship)
  values (auth.uid(), v_member_id, 'self');

  return v_member_id;
end;
$$;

revoke all on function public.complete_captain_signup(text, text, text, date) from public;
grant execute on function public.complete_captain_signup(text, text, text, date) to authenticated;

-- Neither of the two functions below takes a chapter id/key param — they
-- only join event_attendees_chapter.chapter_key to members.chapter_key, both
-- of which are renamed to chapter_key above — but a `language sql`
-- function's body is re-resolved by column name on each call, not rewritten
-- on a column rename the way a view's is, so these still need recreating.

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
    on eac.event_id = p_event_id and eac.chapter_key = m.chapter_key
  where eac.role = 'chapter'
     or (eac.role = 'captains' and m.role in ('captain', 'commander'))
     or (eac.role = 'brothers' and m.role = 'brother')
  union
  select member_id
  from public.event_attendees_specific
  where event_id = p_event_id;
$$;

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
    on eac.event_id = p_event_id and eac.chapter_key = m.chapter_key
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
