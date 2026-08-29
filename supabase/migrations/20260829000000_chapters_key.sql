-- Stable natural key, distinct from id — becomes the FK target for every
-- table that references chapters, in place of chapter_id/host_chapter_id
-- (see 20260829000500_chapter_fk_use_key.sql).
alter table public.chapters
  add column key text not null unique;
