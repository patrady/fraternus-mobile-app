-- A Challenge only stays "current" within 3 weeks of its Frat Night —
-- past that, a chapter that hasn't met in a while should show no current
-- challenge rather than an arbitrarily stale one.
--
-- p_chapter_key is now chapters.key (text), not chapters.id (uuid) — CREATE
-- OR REPLACE can't change a parameter's type, so the uuid-arg version is
-- dropped first rather than left behind as a dangling overload.
drop function if exists public.get_current_challenge(uuid, timestamptz);

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
