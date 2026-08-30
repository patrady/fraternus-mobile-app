-- Seed event_attendees_chapter from each event file's `chapter_key/attendees`
-- column (comma-separated chapter_key/role pairs). References the events
-- seeded by the prior 4 migrations directly by their explicit ids, rather
-- than correlating rows by title (title drift between this file and an
-- events seed migration previously left frat nights with zero attendee
-- rows — see the frat-night RSVP bug this replaced).

insert into public.event_attendees_chapter (event_id, chapter_key, role)
values
  -- Commitment Ceremony (custom)
  ('3160bf41-01d8-4c20-abb7-109928f64788', 'st_philip_franklin_tn', 'chapter'),
  -- Excursion #1: Battle (same 6-chapter list for all 4 excursions)
  ('a6e18f09-c712-485f-b6d3-7014ccc3859c', 'st_philip_franklin_tn', 'chapter'),
  ('a6e18f09-c712-485f-b6d3-7014ccc3859c', 'sacred_heart_lawrenceburg_tn', 'chapter'),
  ('a6e18f09-c712-485f-b6d3-7014ccc3859c', 'st_rose_of_lima_murfreesboro_tn', 'chapter'),
  ('a6e18f09-c712-485f-b6d3-7014ccc3859c', 'overbrook_catholic_school_nashville_tn', 'chapter'),
  ('a6e18f09-c712-485f-b6d3-7014ccc3859c', 'st_edwards_nashville_tn', 'chapter'),
  ('a6e18f09-c712-485f-b6d3-7014ccc3859c', 'our_lady_of_the_lake_hendersonville_tn', 'chapter'),
  -- Excursion #2: Beauty
  ('c4995ce8-2e35-463f-aeb5-ef4ecb3816de', 'st_philip_franklin_tn', 'chapter'),
  ('c4995ce8-2e35-463f-aeb5-ef4ecb3816de', 'sacred_heart_lawrenceburg_tn', 'chapter'),
  ('c4995ce8-2e35-463f-aeb5-ef4ecb3816de', 'st_rose_of_lima_murfreesboro_tn', 'chapter'),
  ('c4995ce8-2e35-463f-aeb5-ef4ecb3816de', 'overbrook_catholic_school_nashville_tn', 'chapter'),
  ('c4995ce8-2e35-463f-aeb5-ef4ecb3816de', 'st_edwards_nashville_tn', 'chapter'),
  ('c4995ce8-2e35-463f-aeb5-ef4ecb3816de', 'our_lady_of_the_lake_hendersonville_tn', 'chapter'),
  -- Pre-Lenten Retreat
  ('15cd9c07-2074-40d6-a339-7bc1b71b2672', 'st_philip_franklin_tn', 'chapter'),
  ('15cd9c07-2074-40d6-a339-7bc1b71b2672', 'sacred_heart_lawrenceburg_tn', 'chapter'),
  ('15cd9c07-2074-40d6-a339-7bc1b71b2672', 'st_rose_of_lima_murfreesboro_tn', 'chapter'),
  ('15cd9c07-2074-40d6-a339-7bc1b71b2672', 'overbrook_catholic_school_nashville_tn', 'chapter'),
  ('15cd9c07-2074-40d6-a339-7bc1b71b2672', 'st_edwards_nashville_tn', 'chapter'),
  ('15cd9c07-2074-40d6-a339-7bc1b71b2672', 'our_lady_of_the_lake_hendersonville_tn', 'chapter'),
  -- Excursion #3: Adventure
  ('840c5e4f-dad8-4728-b044-67be4da2d18b', 'st_philip_franklin_tn', 'chapter'),
  ('840c5e4f-dad8-4728-b044-67be4da2d18b', 'sacred_heart_lawrenceburg_tn', 'chapter'),
  ('840c5e4f-dad8-4728-b044-67be4da2d18b', 'st_rose_of_lima_murfreesboro_tn', 'chapter'),
  ('840c5e4f-dad8-4728-b044-67be4da2d18b', 'overbrook_catholic_school_nashville_tn', 'chapter'),
  ('840c5e4f-dad8-4728-b044-67be4da2d18b', 'st_edwards_nashville_tn', 'chapter'),
  ('840c5e4f-dad8-4728-b044-67be4da2d18b', 'our_lady_of_the_lake_hendersonville_tn', 'chapter'),
  -- Ranch 2027 (all 33 chapters)
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_paul_birmingham_al', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'holy_spirit_huntsville_al', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_isidore_yuba_city_ca', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_patrick_jacksonville_fl', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'christ_the_king_tampa_fl', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'mary_our_queen_peachtree_corners_ga', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_louis_de_montfort_fishers_in', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_elizabeth_ann_seton_fort_wayne_in', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_james_elizabethtown_ky', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'sacred_heart_of_jesus_baton_rouge_la', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_margaret_of_scotland_lake_charles_la', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_bridget_schriever_la', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'corpus_christi_e_sandwich_ma', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_anns_charlotte_nc', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_aloysius_hickory_nc', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_mark_huntersville_nc', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_john_the_baptist_tryon_nc', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_catherine_of_siena_wake_forest_nc', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'our_lady_of_pompeii_lancaster_ny', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_mary_help_of_christians_aiken_sc', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'saint_marys_greenville_sc', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_andrew_myrtle_beach_sc', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'prince_of_peace_taylors_sc', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_philip_franklin_tn', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'holy_ghost_knoxville_tn', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'sacred_heart_lawrenceburg_tn', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_rose_of_lima_murfreesboro_tn', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'overbrook_catholic_school_nashville_tn', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'st_edwards_nashville_tn', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'nativity_thompsons_station_tn', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'our_lady_of_the_lake_hendersonville_tn', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'our_lady_star_of_the_sea_bremerton_wa', 'chapter'),
  ('d852075f-09e4-4922-951a-956649b74dcc', 'holy_redeemer_vancouver_wa', 'chapter'),
  -- Frat Nights
  ('43431db0-8024-4259-a9b8-d58758448e3e', 'st_philip_franklin_tn', 'chapter'), -- Rush Night #1
  ('ea11b4d9-da74-444c-92e9-521c61d7136d', 'st_philip_franklin_tn', 'chapter'), -- Rush Night #2
  ('a80c1f43-aeeb-4c8a-ba85-bd8d7effbf52', 'st_philip_franklin_tn', 'chapter'), -- Rush Night #3
  ('a5e9ecd6-5203-43db-b65e-32220bd83fbe', 'st_philip_franklin_tn', 'chapter'), -- Rush Night #4
  ('f7107ff1-7e9c-4d7f-931f-1175c17d703d', 'st_philip_franklin_tn', 'chapter'), -- Humility vs Pride
  ('6bae4fd8-20cd-42bf-813d-751f82b9e8e2', 'st_philip_franklin_tn', 'chapter'), -- Generosity vs Greed
  ('0948eb77-d49c-4c6f-abbb-557e1550002f', 'st_philip_franklin_tn', 'chapter'), -- Kindness vs Envy
  ('acc7b450-6709-4c55-bc8b-a07c707e1f4c', 'st_philip_franklin_tn', 'chapter'), -- Temperance vs Gluttony
  ('f555b579-2c2b-4c00-9f08-f5dd0700cf57', 'st_philip_franklin_tn', 'chapter'); -- Chastity vs Lust
