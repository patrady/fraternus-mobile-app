-- Shared reference/seed content: Chapters and the Frat Night template
-- catalog. Not user-specific — read for authenticated (and, for chapters,
-- anon — needed by the signup screens' chapter picker before a session
-- exists) users, writable only via service_role (seed.sql / direct SQL)
-- since there's no admin UI yet per app_concept.md.

create table public.chapters (
  id uuid primary key default gen_random_uuid(),
  -- Stable natural key (distinct from id) — the FK target for every table
  -- that references a chapter, in place of a raw id/host_id.
  key text not null unique,
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
  to anon, authenticated
  using (true);

create table public.frat_night_templates (
  id uuid primary key default gen_random_uuid(),
  -- Stable natural key (distinct from id) — the FK target for challenges and
  -- event_frat_night_details, in place of a raw id.
  key text not null unique,
  title text not null,
  description text not null,
  reading text not null, -- markdown
  -- Optional video clip to accompany the reading.
  video_clip_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- No date column here: a template has no date of its own — its effective
-- date is whichever Event references it via
-- event_frat_night_details.frat_night_template_key (see the events
-- migration's unique constraint on that column).
--
-- field_guide_week_id is added later, by the field_guide migration — it
-- can't be added here since public.field_guide_weeks doesn't exist yet at
-- this point in migration order.

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
grant select on public.chapters to anon, authenticated;
grant select on public.frat_night_templates to authenticated;
