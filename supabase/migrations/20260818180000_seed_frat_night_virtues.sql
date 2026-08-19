-- Add a `key` column (lowercase form of `name`) to frat_night_virtues and
-- seed the seven canonical virtues.

alter table public.frat_night_virtues
  add column key text;

insert into public.frat_night_virtues (name, key)
values
  ('Faith', 'faith'),
  ('Hope', 'hope'),
  ('Charity', 'charity'),
  ('Fortitude', 'fortitude'),
  ('Justice', 'justice'),
  ('Prudence', 'prudence'),
  ('Temperance', 'temperance')
on conflict (name) do update set key = excluded.key;

update public.frat_night_virtues
  set key = lower(name)
  where key is null;

alter table public.frat_night_virtues
  alter column key set not null;

alter table public.frat_night_virtues
  add constraint frat_night_virtues_key_key unique (key);
