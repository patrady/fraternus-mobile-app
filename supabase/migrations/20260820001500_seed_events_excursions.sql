-- Seed the Excursion events, from data/events/excursions.md.

with new_events as (
  insert into public.events (type, title, description, location, start_date, end_date)
  values
    ('excursion', 'Excursion #1: Battle', 'Explore battle', 'David Crocket State Park, Lawrenceburg, TN', '2026-09-11 18:00:00-06', '2026-09-13 12:00:00-06'),
    ('excursion', 'Excursion #2: Beauty', 'Explore beauty', 'Camp Woodlee, McMinnville, TN', '2026-11-06 18:00:00-05', '2026-11-08 12:00:00-05'),
    ('excursion', 'Pre-Lenten Retreat', 'Get ready for Lent', 'Eagle Ridge Retreat Center, Bowling Green, KY', '2027-02-05 18:00:00-05', '2027-02-07 12:00:00-05'),
    ('excursion', 'Excursion #3: Adventure', 'Explore adventure', 'Andrews Spring Farm, Lewisburg, TN', '2027-04-16 18:00:00-06', '2027-04-18 12:00:00-06')
  returning id, title
)
insert into public.event_excursion_details (event_id, host_chapter_key, registration_url)
select ne.id, v.host_chapter_key, v.registration_url
from new_events ne
join (values
  ('Excursion #1: Battle', 'st_edwards_nashville_tn', null::text),
  ('Excursion #2: Beauty', 'st_philip_franklin_tn', null::text),
  ('Pre-Lenten Retreat', 'nativity_thompsons_station_tn', null::text),
  ('Excursion #3: Adventure', 'our_lady_of_the_lake_hendersonville_tn', null::text)
) as v(title, host_chapter_key, registration_url)
on v.title = ne.title;
