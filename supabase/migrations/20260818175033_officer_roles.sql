-- Officer Roles: Commander, HAWC Officer, Frat Night Officer, Excursion
-- Officer. A Member can hold any combination of these at once (hence a
-- join table rather than a single nullable column), each with a fixed
-- priority so the client can pick one to show as a badge when it only has
-- room for one (see get_event_attendees below, and Member.topOfficerRole
-- in the Flutter app). Distinct from `is_hawc`, which is a plain
-- participation flag (any Member can be "in HAWC") rather than a
-- leadership title.
--
-- Like Chapters and Frat Night Templates, officer_roles is a small,
-- hand-seeded reference table (key-referenced, no admin UI) — see
-- reference_content.sql for that established pattern. member_officer_roles
-- is likewise hand-assigned via Studio/SQL, same as
-- 20260905000000_app_version_lockout.sql's tables: RLS + grants allow
-- `authenticated` to read, nothing lets it write.

alter table public.members
  add column is_hawc boolean not null default false;

create table public.officer_roles (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  label text not null,
  priority integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint officer_roles_priority_unique unique (priority)
);

insert into public.officer_roles (key, label, priority) values
  ('commander', 'Commander', 1),
  ('hawc_officer', 'HAWC Officer', 2),
  ('frat_night_officer', 'Frat Night Officer', 3),
  ('excursion_officer', 'Excursion Officer', 4);

create table public.member_officer_roles (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members (id) on delete cascade,
  officer_role_key text not null references public.officer_roles (key),
  created_at timestamptz not null default now(),
  constraint member_officer_roles_unique unique (member_id, officer_role_key)
);

alter table public.officer_roles enable row level security;

create policy "select officer roles"
  on public.officer_roles for select
  to authenticated
  using (true);

grant select on public.officer_roles to authenticated;

alter table public.member_officer_roles enable row level security;

create policy "select own household officer roles"
  on public.member_officer_roles for select
  to authenticated
  using (public.has_member_association(member_id));

grant select on public.member_officer_roles to authenticated;
