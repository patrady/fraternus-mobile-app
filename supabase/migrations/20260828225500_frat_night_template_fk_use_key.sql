-- Point challenges and event_frat_night_details at frat_night_templates by
-- the `key` natural key instead of `id`, same reasoning/pattern as the
-- earlier frat_night_templates_frat_night_virtue_key migration.
--
-- Can't do this as a single `alter column ... type text using (...)` — a
-- correlated subquery isn't allowed in an ALTER COLUMN TYPE USING clause
-- (SQLSTATE 0A000). Add-populate-drop-rename instead.

alter table public.challenges
  drop constraint challenges_frat_night_template_id_fkey;

alter table public.challenges
  rename column frat_night_template_id to frat_night_template_id_old;

alter table public.challenges
  add column frat_night_template_key text;

update public.challenges c
set frat_night_template_key = t.key
from public.frat_night_templates t
where t.id = c.frat_night_template_id_old;

alter table public.challenges
  alter column frat_night_template_key set not null;

alter table public.challenges
  drop column frat_night_template_id_old;

alter table public.challenges
  add constraint challenges_frat_night_template_key_fkey
    foreign key (frat_night_template_key) references public.frat_night_templates (key) on delete restrict;

alter table public.event_frat_night_details
  drop constraint event_frat_night_details_frat_night_template_id_fkey;

alter table public.event_frat_night_details
  rename column frat_night_template_id to frat_night_template_id_old;

alter table public.event_frat_night_details
  add column frat_night_template_key text;

update public.event_frat_night_details d
set frat_night_template_key = t.key
from public.frat_night_templates t
where t.id = d.frat_night_template_id_old;

alter table public.event_frat_night_details
  alter column frat_night_template_key set not null;

alter table public.event_frat_night_details
  drop column frat_night_template_id_old;

alter table public.event_frat_night_details
  add constraint event_frat_night_details_frat_night_template_key_fkey
    foreign key (frat_night_template_key) references public.frat_night_templates (key) on delete restrict;
