-- A Frat Night Template's date is now whatever Event references it
-- (event_frat_night_details -> events.start_date), not a separately
-- hardcoded field — "current" resolution already works this way via
-- get_current_challenge; this removes the redundant, hand-maintained
-- duplicate and the seeding step that would otherwise have to invent it.
--
-- The old unique start_of_week_date column used to guarantee "one
-- template per calendar week" / effectively "one event per template".
-- Replace that guarantee with a real constraint on the actual
-- relationship: at most one Event per Frat Night Template.

alter table public.frat_night_templates
  drop constraint frat_night_templates_start_of_week_date_key;

alter table public.frat_night_templates
  drop column start_of_week_date;

alter table public.event_frat_night_details
  add constraint event_frat_night_details_frat_night_template_key_key
    unique (frat_night_template_key);
