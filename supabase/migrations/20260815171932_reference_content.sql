-- Shared reference/seed content: Chapters, Field Guide school-year
-- configuration, and Frat Night virtue/template catalog. Not user-specific
-- — read-only for authenticated users, writable only via service_role
-- (seed.sql / direct SQL) since there's no admin UI yet per app_concept.md.

create table public.chapters (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text not null,
  state text not null,
  zip_code text not null,
  timezone text not null, -- IANA identifier, e.g. 'America/Chicago'
  church text not null,
  frat_night_day_of_week text not null, -- lowercase, e.g. 'wednesday'
  frat_night_start_time time not null,
  frat_night_end_time time not null,
  frat_night_location text not null
);

alter table public.chapters enable row level security;

create policy "read chapters"
  on public.chapters for select
  to authenticated
  using (true);

create table public.chapter_field_guide_details (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references public.chapters (id) on delete cascade,
  school_year_start_date date not null,
  school_year_end_date date not null,
  field_guide_start_date date not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.chapter_field_guide_details enable row level security;

create policy "read chapter field guide details"
  on public.chapter_field_guide_details for select
  to authenticated
  using (true);

create trigger set_chapter_field_guide_details_updated_at
  before update on public.chapter_field_guide_details
  for each row
  execute function public.set_updated_at();

create index idx_chapter_field_guide_details_chapter_id
  on public.chapter_field_guide_details (chapter_id);

create table public.frat_night_virtues (
  id uuid primary key default gen_random_uuid(),
  name text not null unique
);

alter table public.frat_night_virtues enable row level security;

create policy "read frat night virtues"
  on public.frat_night_virtues for select
  to authenticated
  using (true);

create table public.frat_night_templates (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  reading text not null, -- markdown
  liturgical_day text not null,
  start_of_week_date date not null unique,
  frat_night_virtue_id uuid not null references public.frat_night_virtues (id) on delete restrict,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.frat_night_templates enable row level security;

create policy "read frat night templates"
  on public.frat_night_templates for select
  to authenticated
  using (true);

create trigger set_frat_night_templates_updated_at
  before update on public.frat_night_templates
  for each row
  execute function public.set_updated_at();

-- Base table-level grants — RLS above governs row visibility, but Postgres
-- requires this separate grant before RLS is even evaluated (see the
-- comment in the public_users migration for how this was verified).
grant select on public.chapters to authenticated;
grant select on public.chapter_field_guide_details to authenticated;
grant select on public.frat_night_virtues to authenticated;
grant select on public.frat_night_templates to authenticated;

create index idx_frat_night_templates_virtue_id
  on public.frat_night_templates (frat_night_virtue_id);
