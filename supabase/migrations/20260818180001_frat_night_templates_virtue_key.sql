-- Point frat_night_templates at frat_night_virtues by the new `key` natural
-- key instead of `id`, now that virtues are seeded with stable keys.
--
-- Can't do this as a single `alter column ... type text using (...)` — a
-- correlated subquery isn't allowed in an ALTER COLUMN TYPE USING clause
-- (SQLSTATE 0A000). Add-populate-drop-rename instead.

alter table public.frat_night_templates
  drop constraint frat_night_templates_frat_night_virtue_id_fkey;

drop index public.idx_frat_night_templates_virtue_id;

alter table public.frat_night_templates
  rename column frat_night_virtue_id to frat_night_virtue_id_old;

alter table public.frat_night_templates
  add column frat_night_virtue_key text;

update public.frat_night_templates t
set frat_night_virtue_key = v.key
from public.frat_night_virtues v
where v.id = t.frat_night_virtue_id_old;

alter table public.frat_night_templates
  alter column frat_night_virtue_key set not null;

alter table public.frat_night_templates
  drop column frat_night_virtue_id_old;

alter table public.frat_night_templates
  add constraint frat_night_templates_frat_night_virtue_key_fkey
    foreign key (frat_night_virtue_key) references public.frat_night_virtues (key) on delete restrict;

create index idx_frat_night_templates_virtue_key
  on public.frat_night_templates (frat_night_virtue_key);
