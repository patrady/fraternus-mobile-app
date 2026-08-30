-- Seed the Excursion events, from data/events/excursions.md. Explicit ids
-- so the detail-table insert below (and the event_attendees_chapter seed
-- migration) can reference each event directly, instead of correlating
-- rows by title.

insert into public.events (id, type, title, description, event_location_id, start_date, end_date)
values
  ('a6e18f09-c712-485f-b6d3-7014ccc3859c', 'excursion', 'Excursion #1: Battle', 'Explore battle', '21a88317-9fd8-4b96-8c2f-784092b24c78', '2026-09-11 18:00:00-05', '2026-09-13 12:00:00-05'),
  ('c4995ce8-2e35-463f-aeb5-ef4ecb3816de', 'excursion', 'Excursion #2: Beauty', 'Explore beauty', 'ae8c3c8e-9346-417a-95a0-72057fb14eda', '2026-11-06 18:00:00-06', '2026-11-08 12:00:00-06'),
  ('15cd9c07-2074-40d6-a339-7bc1b71b2672', 'excursion', 'Pre-Lenten Retreat', 'Get ready for Lent', 'd4aea776-6fb9-4970-8a4e-deee59bc3c07', '2027-02-05 18:00:00-06', '2027-02-07 12:00:00-06'),
  ('840c5e4f-dad8-4728-b044-67be4da2d18b', 'excursion', 'Excursion #3: Adventure', 'Explore adventure', '135d9c0d-93ac-4166-86d5-d53d4834634a', '2027-04-16 18:00:00-05', '2027-04-18 12:00:00-05');

insert into public.event_excursion_details (event_id, host_chapter_key, registration_url)
values
  ('a6e18f09-c712-485f-b6d3-7014ccc3859c', 'st_edwards_nashville_tn', null::text),
  ('c4995ce8-2e35-463f-aeb5-ef4ecb3816de', 'st_philip_franklin_tn', null::text),
  ('15cd9c07-2074-40d6-a339-7bc1b71b2672', 'nativity_thompsons_station_tn', null::text),
  ('840c5e4f-dad8-4728-b044-67be4da2d18b', 'our_lady_of_the_lake_hendersonville_tn', null::text);
