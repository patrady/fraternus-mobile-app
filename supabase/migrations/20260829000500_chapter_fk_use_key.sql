-- Point every table that references chapters at the `key` natural key
-- instead of `id`, same reasoning/pattern as the frat_night_template_fk_use_key
-- migration.
--
-- Can't do this as a single `alter column ... type text using (...)` — a
-- correlated subquery isn't allowed in an ALTER COLUMN TYPE USING clause
-- (SQLSTATE 0A000). Add-populate-drop-rename instead, per table.

-- chapter_field_guide_details.chapter_id -----------------------------------

alter table public.chapter_field_guide_details
  drop constraint chapter_field_guide_details_chapter_id_fkey;

drop index public.idx_chapter_field_guide_details_chapter_id;

alter table public.chapter_field_guide_details
  rename column chapter_id to chapter_id_old;

alter table public.chapter_field_guide_details
  add column chapter_key text;

update public.chapter_field_guide_details d
set chapter_key = c.key
from public.chapters c
where c.id = d.chapter_id_old;

alter table public.chapter_field_guide_details
  alter column chapter_key set not null;

alter table public.chapter_field_guide_details
  drop column chapter_id_old;

alter table public.chapter_field_guide_details
  add constraint chapter_field_guide_details_chapter_key_fkey
    foreign key (chapter_key) references public.chapters (key) on delete cascade;

create index idx_chapter_field_guide_details_chapter_key
  on public.chapter_field_guide_details (chapter_key);

-- members.chapter_id --------------------------------------------------------

alter table public.members
  drop constraint members_chapter_id_fkey;

drop index public.idx_members_chapter_id;

alter table public.members
  rename column chapter_id to chapter_id_old;

alter table public.members
  add column chapter_key text;

update public.members m
set chapter_key = c.key
from public.chapters c
where c.id = m.chapter_id_old;

alter table public.members
  alter column chapter_key set not null;

alter table public.members
  drop column chapter_id_old;

alter table public.members
  add constraint members_chapter_key_fkey
    foreign key (chapter_key) references public.chapters (key) on delete restrict;

create index idx_members_chapter_key on public.members (chapter_key);

-- event_frat_night_details.chapter_id ---------------------------------------

alter table public.event_frat_night_details
  drop constraint event_frat_night_details_chapter_id_fkey;

alter table public.event_frat_night_details
  rename column chapter_id to chapter_id_old;

alter table public.event_frat_night_details
  add column chapter_key text;

update public.event_frat_night_details d
set chapter_key = c.key
from public.chapters c
where c.id = d.chapter_id_old;

alter table public.event_frat_night_details
  alter column chapter_key set not null;

alter table public.event_frat_night_details
  drop column chapter_id_old;

alter table public.event_frat_night_details
  add constraint event_frat_night_details_chapter_key_fkey
    foreign key (chapter_key) references public.chapters (key) on delete restrict;

-- event_excursion_details.host_chapter_id ------------------------------------

alter table public.event_excursion_details
  drop constraint event_excursion_details_host_chapter_id_fkey;

alter table public.event_excursion_details
  rename column host_chapter_id to host_chapter_id_old;

alter table public.event_excursion_details
  add column host_chapter_key text;

update public.event_excursion_details d
set host_chapter_key = c.key
from public.chapters c
where c.id = d.host_chapter_id_old;

alter table public.event_excursion_details
  alter column host_chapter_key set not null;

alter table public.event_excursion_details
  drop column host_chapter_id_old;

alter table public.event_excursion_details
  add constraint event_excursion_details_host_chapter_key_fkey
    foreign key (host_chapter_key) references public.chapters (key) on delete restrict;

-- event_attendees_chapter.chapter_id -----------------------------------------

alter table public.event_attendees_chapter
  drop constraint event_attendees_chapter_chapter_id_fkey;

alter table public.event_attendees_chapter
  rename column chapter_id to chapter_id_old;

alter table public.event_attendees_chapter
  add column chapter_key text;

update public.event_attendees_chapter d
set chapter_key = c.key
from public.chapters c
where c.id = d.chapter_id_old;

alter table public.event_attendees_chapter
  alter column chapter_key set not null;

alter table public.event_attendees_chapter
  drop column chapter_id_old;

alter table public.event_attendees_chapter
  add constraint event_attendees_chapter_chapter_key_fkey
    foreign key (chapter_key) references public.chapters (key) on delete restrict;
