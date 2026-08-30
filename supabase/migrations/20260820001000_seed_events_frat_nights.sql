-- Seed the Year 1 Frat Night events, from data/events/frat_nights.md.
-- Explicit ids so the detail-table insert below (and the
-- event_attendees_chapter seed migration) can reference each event
-- directly, instead of correlating rows by title.

insert into public.events (id, type, title, description, event_location_id, start_date, end_date)
values
  ('43431db0-8024-4259-a9b8-d58758448e3e', 'frat_night', 'Frat Night: Rush Night #1', 'First week of Fraternus Rush', '9f9bae55-a5d9-473f-8eee-79d4da2b18e1', '2026-08-18 18:30:00-05', '2026-08-18 20:30:00-05'),
  ('ea11b4d9-da74-444c-92e9-521c61d7136d', 'frat_night', 'Frat Night: Rush Night #2', 'Second week of Fraternus Rush', '9f9bae55-a5d9-473f-8eee-79d4da2b18e1', '2026-08-25 18:30:00-05', '2026-08-25 20:30:00-05'),
  ('a80c1f43-aeeb-4c8a-ba85-bd8d7effbf52', 'frat_night', 'Frat Night: Rush Night #3', 'Third week of Fraternus Rush', '9f9bae55-a5d9-473f-8eee-79d4da2b18e1', '2026-09-01 18:30:00-05', '2026-09-01 20:30:00-05'),
  ('a5e9ecd6-5203-43db-b65e-32220bd83fbe', 'frat_night', 'Frat Night: Rush Night #4', 'Fourth week of Fraternus Rush', '9f9bae55-a5d9-473f-8eee-79d4da2b18e1', '2026-09-08 18:30:00-05', '2026-09-08 20:30:00-05'),
  ('f7107ff1-7e9c-4d7f-931f-1175c17d703d', 'frat_night', 'Frat Night: Humility vs Pride', null, '9f9bae55-a5d9-473f-8eee-79d4da2b18e1', '2026-09-15 18:30:00-05', '2026-09-15 20:30:00-05'),
  ('6bae4fd8-20cd-42bf-813d-751f82b9e8e2', 'frat_night', 'Frat Night: Generosity vs Greed', null, '9f9bae55-a5d9-473f-8eee-79d4da2b18e1', '2026-09-22 18:30:00-05', '2026-09-22 20:30:00-05'),
  ('0948eb77-d49c-4c6f-abbb-557e1550002f', 'frat_night', 'Frat Night: Kindness vs Envy', null, '9f9bae55-a5d9-473f-8eee-79d4da2b18e1', '2026-09-29 18:30:00-05', '2026-09-29 20:30:00-05'),
  ('acc7b450-6709-4c55-bc8b-a07c707e1f4c', 'frat_night', 'Frat Night: Temperance vs Gluttony', null, '9f9bae55-a5d9-473f-8eee-79d4da2b18e1', '2026-10-05 18:30:00-05', '2026-10-05 20:30:00-05'),
  ('f555b579-2c2b-4c00-9f08-f5dd0700cf57', 'frat_night', 'Frat Night: Chastity vs Lust', null, '9f9bae55-a5d9-473f-8eee-79d4da2b18e1', '2026-10-13 18:30:00-05', '2026-10-13 20:30:00-05');

insert into public.event_frat_night_details (event_id, frat_night_template_key, chapter_key)
values
  ('43431db0-8024-4259-a9b8-d58758448e3e', 'year_1_rush_night_1', 'st_philip_franklin_tn'),
  ('ea11b4d9-da74-444c-92e9-521c61d7136d', 'year_1_rush_night_2', 'st_philip_franklin_tn'),
  ('a80c1f43-aeeb-4c8a-ba85-bd8d7effbf52', 'year_1_rush_night_3', 'st_philip_franklin_tn'),
  ('a5e9ecd6-5203-43db-b65e-32220bd83fbe', 'year_1_rush_night_4', 'st_philip_franklin_tn'),
  ('f7107ff1-7e9c-4d7f-931f-1175c17d703d', 'year_1_week_27', 'st_philip_franklin_tn'),
  ('6bae4fd8-20cd-42bf-813d-751f82b9e8e2', 'year_1_week_28', 'st_philip_franklin_tn'),
  ('0948eb77-d49c-4c6f-abbb-557e1550002f', 'year_1_week_29', 'st_philip_franklin_tn'),
  ('acc7b450-6709-4c55-bc8b-a07c707e1f4c', 'year_1_week_30', 'st_philip_franklin_tn'),
  ('f555b579-2c2b-4c00-9f08-f5dd0700cf57', 'year_1_week_31', 'st_philip_franklin_tn');
