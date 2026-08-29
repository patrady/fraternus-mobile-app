-- Stable natural key, distinct from id — becomes the FK target for
-- challenges/event_frat_night_details in place of frat_night_template_id
-- (see 20260828225500_frat_night_template_fk_use_key.sql).
alter table public.frat_night_templates
  add column key text not null unique;
