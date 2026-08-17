-- Events: Frat Nights, Excursions, Ranch, and custom events, plus the two
-- attendee-eligibility tables and RSVPs. Phase 4 only needs enough of this
-- to prove the event-cancellation server-push pipeline (events +
-- event_attendees_chapter/specific, to resolve who gets notified) — the
-- rest of the Events *feature* (SupabaseEventsRepository, RSVP submission)
-- is Phase 7. Building the full schema now regardless, since these tables
-- are small and this avoids a second migration touching the same table
-- group later.

create table public.events (
  id uuid primary key default gen_random_uuid(),
  type event_type not null,
  title text not null,
  description text,
  location text,
  start_date timestamptz not null,
  end_date timestamptz not null,
  cancellation_date timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger set_events_updated_at
  before update on public.events
  for each row
  execute function public.set_updated_at();

create index idx_events_start_date on public.events (start_date);

alter table public.events enable row level security;

create policy "read events"
  on public.events for select
  to authenticated
  using (true);

create table public.event_frat_night_details (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null unique references public.events (id) on delete cascade,
  frat_night_template_id uuid not null references public.frat_night_templates (id) on delete restrict,
  chapter_id uuid not null references public.chapters (id) on delete restrict
);

alter table public.event_frat_night_details enable row level security;

create policy "read event frat night details"
  on public.event_frat_night_details for select
  to authenticated
  using (true);

create table public.event_excursion_details (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null unique references public.events (id) on delete cascade,
  host_chapter_id uuid not null references public.chapters (id) on delete restrict,
  registration_url text
);

alter table public.event_excursion_details enable row level security;

create policy "read event excursion details"
  on public.event_excursion_details for select
  to authenticated
  using (true);

create table public.event_ranch_details (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null unique references public.events (id) on delete cascade,
  registration_url text
);

alter table public.event_ranch_details enable row level security;

create policy "read event ranch details"
  on public.event_ranch_details for select
  to authenticated
  using (true);

create table public.event_attendees_chapter (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events (id) on delete cascade,
  chapter_id uuid not null references public.chapters (id) on delete restrict,
  role event_attendee_chapter_role not null
);

create index idx_event_attendees_chapter_event_id on public.event_attendees_chapter (event_id);

alter table public.event_attendees_chapter enable row level security;

create policy "read event attendees chapter"
  on public.event_attendees_chapter for select
  to authenticated
  using (true);

-- User-generated (ADR 0003 cascade target): names a specific Member.
create table public.event_attendees_specific (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events (id) on delete cascade,
  member_id uuid not null references public.members (id) on delete cascade
);

create index idx_event_attendees_specific_event_id on public.event_attendees_specific (event_id);
create index idx_event_attendees_specific_member_id on public.event_attendees_specific (member_id);

alter table public.event_attendees_specific enable row level security;

-- A member can only see their own specific-invite rows (via
-- has_member_association), not everyone else's — this table doesn't need
-- an "authenticated read everything" policy the way event_attendees_chapter
-- does, since a chapter-wide rule is inherently non-sensitive but "who
-- specifically was invited" names individuals.
create policy "select own specific invites"
  on public.event_attendees_specific for select
  to authenticated
  using (public.has_member_association(member_id));

-- No insert/update/delete policy: specific invites are seeded/managed
-- content, same as event_attendees_chapter — no admin UI yet per
-- app_concept.md, so there's nothing for a client to write here.

-- User-generated (ADR 0003 cascade target).
create table public.event_rsvps (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events (id) on delete cascade,
  member_id uuid not null references public.members (id) on delete cascade,
  submitted_by_user_id uuid references public.users (id) on delete set null,
  response rsvp_response not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, member_id)
);

create trigger set_event_rsvps_updated_at
  before update on public.event_rsvps
  for each row
  execute function public.set_updated_at();

create trigger set_event_rsvps_submitted_by_user_id
  before insert on public.event_rsvps
  for each row
  execute function public.set_submitted_by_user_id();

create index idx_event_rsvps_event_id on public.event_rsvps (event_id);
create index idx_event_rsvps_member_id on public.event_rsvps (member_id);

alter table public.event_rsvps enable row level security;

create policy "select own household rsvps"
  on public.event_rsvps for select
  to authenticated
  using (public.has_member_association(member_id));

create policy "insert own household rsvps"
  on public.event_rsvps for insert
  to authenticated
  with check (
    public.has_member_association(member_id)
    and public.member_is_write_active(member_id)
  );

create policy "update own household rsvps"
  on public.event_rsvps for update
  to authenticated
  using (public.has_member_association(member_id))
  with check (
    public.has_member_association(member_id)
    and public.member_is_write_active(member_id)
  );

-- No delete policy: the "un-RSVP" flow is a toggle-to-delete RPC
-- (submit_event_rsvp, Phase 7), which runs as the caller and is still
-- subject to RLS — but DELETE itself has no policy here, matching the
-- pattern on every other user-generated table; Phase 7's RPC will need a
-- delete policy added alongside it, since without one the RPC's own DELETE
-- would be blocked exactly like a raw client DELETE would be. Flagged here
-- rather than added speculatively now, since no delete path exists yet.

-- Base table-level grants — see the comment in the public_users migration
-- for why these are necessary in addition to the RLS policies above.
grant select on public.events to authenticated;
grant select on public.event_frat_night_details to authenticated;
grant select on public.event_excursion_details to authenticated;
grant select on public.event_ranch_details to authenticated;
grant select on public.event_attendees_chapter to authenticated;
grant select on public.event_attendees_specific to authenticated;
grant select, insert, update on public.event_rsvps to authenticated;
