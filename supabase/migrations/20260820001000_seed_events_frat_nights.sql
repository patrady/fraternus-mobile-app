-- Seed the Year 1 Frat Night events, from data/events/frat_nights.md.
-- Correlates the events insert to the detail-table insert by title (all
-- titles in this seed batch are unique) rather than relying on
-- multi-row INSERT...RETURNING ordering.

with new_events as (
  insert into public.events (type, title, description, location, start_date, end_date)
  values
    ('frat_night', 'Rush Night #1', 'First week of Fraternus Rush', 'St. Philips Catholic Church', '2026-08-18 18:30:00-06', '2026-08-18 20:30:00-06'),
    ('frat_night', 'Rush Night #2', 'Second week of Fraternus Rush', 'St. Philips Catholic Church', '2026-08-25 18:30:00-06', '2026-08-25 20:30:00-06'),
    ('frat_night', 'Rush Night #3', 'Third week of Fraternus Rush', 'St. Philips Catholic Church', '2026-09-01 18:30:00-06', '2026-09-01 20:30:00-06'),
    ('frat_night', 'Rush Night #4', 'Fourth week of Fraternus Rush', 'St. Philips Catholic Church', '2026-09-08 18:30:00-06', '2026-09-08 20:30:00-06'),
    ('frat_night', 'Humility vs Pride', null, 'St. Philips Catholic Church', '2026-09-15 18:30:00-06', '2026-09-15 20:30:00-06'),
    ('frat_night', 'Generosity vs Greed', null, 'St. Philips Catholic Church', '2026-09-22 18:30:00-06', '2026-09-22 20:30:00-06'),
    ('frat_night', 'Kindness vs Envy', null, 'St. Philips Catholic Church', '2026-09-29 18:30:00-06', '2026-09-29 20:30:00-06'),
    ('frat_night', 'Temperance vs Gluttony', null, 'St. Philips Catholic Church', '2026-10-06 18:30:00-06', '2026-10-06 20:30:00-06'),
    ('frat_night', 'Chastity vs Lust', null, 'St. Philips Catholic Church', '2026-10-13 18:30:00-06', '2026-10-13 20:30:00-06')
  returning id, title
)
insert into public.event_frat_night_details (event_id, frat_night_template_key, chapter_key)
select ne.id, v.frat_night_template_key, v.chapter_key
from new_events ne
join (values
  ('Rush Night #1', 'year_1_rush_night_1', 'st_philip_franklin_tn'),
  ('Rush Night #2', 'year_1_rush_night_2', 'st_philip_franklin_tn'),
  ('Rush Night #3', 'year_1_rush_night_3', 'st_philip_franklin_tn'),
  ('Rush Night #4', 'year_1_rush_night_4', 'st_philip_franklin_tn'),
  ('Humility vs Pride', 'year_1_week_27', 'st_philip_franklin_tn'),
  ('Generosity vs Greed', 'year_1_week_28', 'st_philip_franklin_tn'),
  ('Kindness vs Envy', 'year_1_week_29', 'st_philip_franklin_tn'),
  ('Temperance vs Gluttony', 'year_1_week_30', 'st_philip_franklin_tn'),
  ('Chastity vs Lust', 'year_1_week_31', 'st_philip_franklin_tn')
) as v(title, frat_night_template_key, chapter_key)
on v.title = ne.title;
