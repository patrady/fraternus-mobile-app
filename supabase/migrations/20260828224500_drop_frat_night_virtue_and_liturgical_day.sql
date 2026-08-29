-- Drop liturgical_day and the frat_night_virtue_key relationship from
-- frat_night_templates — neither was read by any client, and the virtue
-- catalog has no other referencer, so drop frat_night_virtues with it.

alter table public.frat_night_templates
  drop constraint frat_night_templates_frat_night_virtue_key_fkey;

drop index public.idx_frat_night_templates_virtue_key;

alter table public.frat_night_templates
  drop column frat_night_virtue_key;

alter table public.frat_night_templates
  drop column liturgical_day;

drop table public.frat_night_virtues;
