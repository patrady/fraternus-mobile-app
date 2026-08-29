-- Stable natural key, distinct from id — becomes the FK target for every
-- table that references chapters, in place of chapter_id/host_chapter_id
-- (see 20260829000500_chapter_fk_use_key.sql).
--
-- chapters already has 33 seeded rows (20260818180002_seed_chapters.sql)
-- predating this column, so a bare `not null` add would fail — add,
-- backfill, then constrain, matching data/chapters.md's key values.

alter table public.chapters
  add column key text;

update public.chapters set key = 'st_paul_birmingham_al' where name = 'St. Paul' and city = 'Birmingham' and state = 'AL';
update public.chapters set key = 'holy_spirit_huntsville_al' where name = 'Holy Spirit' and city = 'Huntsville' and state = 'AL';
update public.chapters set key = 'st_isidore_yuba_city_ca' where name = 'St. Isidore' and city = 'Yuba City' and state = 'CA';
update public.chapters set key = 'st_patrick_jacksonville_fl' where name = 'St. Patrick' and city = 'Jacksonville' and state = 'FL';
update public.chapters set key = 'christ_the_king_tampa_fl' where name = 'Christ the King' and city = 'Tampa' and state = 'FL';
update public.chapters set key = 'mary_our_queen_peachtree_corners_ga' where name = 'Mary Our Queen' and city = 'Peachtree Corners' and state = 'GA';
update public.chapters set key = 'st_louis_de_montfort_fishers_in' where name = 'St. Louis de Montfort' and city = 'Fishers' and state = 'IN';
update public.chapters set key = 'st_elizabeth_ann_seton_fort_wayne_in' where name = 'St. Elizabeth Ann Seton' and city = 'Fort Wayne' and state = 'IN';
update public.chapters set key = 'st_james_elizabethtown_ky' where name = 'St. James' and city = 'Elizabethtown' and state = 'KY';
update public.chapters set key = 'sacred_heart_of_jesus_baton_rouge_la' where name = 'Sacred Heart of Jesus' and city = 'Baton Rouge' and state = 'LA';
update public.chapters set key = 'st_margaret_of_scotland_lake_charles_la' where name = 'St. Margaret of Scotland' and city = 'Lake Charles' and state = 'LA';
update public.chapters set key = 'st_bridget_schriever_la' where name = 'St. Bridget' and city = 'Schriever' and state = 'LA';
update public.chapters set key = 'corpus_christi_e_sandwich_ma' where name = 'Corpus Christi' and city = 'E. Sandwich' and state = 'MA';
update public.chapters set key = 'st_anns_charlotte_nc' where name = 'St. Ann''s' and city = 'Charlotte' and state = 'NC';
update public.chapters set key = 'st_aloysius_hickory_nc' where name = 'St. Aloysius' and city = 'Hickory' and state = 'NC';
update public.chapters set key = 'st_mark_huntersville_nc' where name = 'St. Mark' and city = 'Huntersville' and state = 'NC';
update public.chapters set key = 'st_john_the_baptist_tryon_nc' where name = 'St. John the Baptist' and city = 'Tryon' and state = 'NC';
update public.chapters set key = 'st_catherine_of_siena_wake_forest_nc' where name = 'St. Catherine of Siena' and city = 'Wake Forest' and state = 'NC';
update public.chapters set key = 'our_lady_of_pompeii_lancaster_ny' where name = 'Our Lady of Pompeii' and city = 'Lancaster' and state = 'NY';
update public.chapters set key = 'st_mary_help_of_christians_aiken_sc' where name = 'St. Mary Help of Christians' and city = 'Aiken' and state = 'SC';
update public.chapters set key = 'saint_marys_greenville_sc' where name = 'Saint Mary''s' and city = 'Greenville' and state = 'SC';
update public.chapters set key = 'st_andrew_myrtle_beach_sc' where name = 'St. Andrew' and city = 'Myrtle Beach' and state = 'SC';
update public.chapters set key = 'prince_of_peace_taylors_sc' where name = 'Prince of Peace' and city = 'Taylors' and state = 'SC';
update public.chapters set key = 'st_philip_franklin_tn' where name = 'St. Philip' and city = 'Franklin' and state = 'TN';
update public.chapters set key = 'holy_ghost_knoxville_tn' where name = 'Holy Ghost' and city = 'Knoxville' and state = 'TN';
update public.chapters set key = 'sacred_heart_lawrenceburg_tn' where name = 'Sacred Heart' and city = 'Lawrenceburg' and state = 'TN';
update public.chapters set key = 'st_rose_of_lima_murfreesboro_tn' where name = 'St. Rose of Lima' and city = 'Murfreesboro' and state = 'TN';
update public.chapters set key = 'overbrook_catholic_school_nashville_tn' where name = 'Overbrook Catholic School' and city = 'Nashville' and state = 'TN';
update public.chapters set key = 'st_edwards_nashville_tn' where name = 'St. Edward''s' and city = 'Nashville' and state = 'TN';
update public.chapters set key = 'nativity_thompsons_station_tn' where name = 'Nativity' and city = 'Thompsons Station' and state = 'TN';
update public.chapters set key = 'our_lady_of_the_lake_hendersonville_tn' where name = 'Our Lady of the Lake' and city = 'Hendersonville' and state = 'TN';
update public.chapters set key = 'our_lady_star_of_the_sea_bremerton_wa' where name = 'Our Lady Star of the Sea' and city = 'Bremerton' and state = 'WA';
update public.chapters set key = 'holy_redeemer_vancouver_wa' where name = 'Holy Redeemer' and city = 'Vancouver' and state = 'WA';

alter table public.chapters
  alter column key set not null;

alter table public.chapters
  add constraint chapters_key_key unique (key);
