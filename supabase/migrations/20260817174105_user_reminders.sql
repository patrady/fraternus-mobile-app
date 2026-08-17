-- User Reminder — per-User, per-type notification preferences (finalized
-- in app_concept.md's Data Models). Sparse override table: absence of a
-- row (or is_enabled = true) means "on" — a new user needs zero rows
-- seeded to have every reminder type enabled by default. Scoped per-User,
-- not per-Member, matching ADR 0001 §5's dedup rule (a Guardian with
-- several kids gets one reminder per type, not one per child).
--
-- reminder_type enum (7 values: field_guide_morning/evening,
-- new_challenge, challenge_mid_week, challenge_last_day, event_24hr/1hr)
-- already exists from the extensions_and_enums migration.
-- Event cancellation is deliberately NOT a reminder_type value — see
-- app_concept.md's note: it's a required correction to stale information a
-- user already opted into (they RSVP'd), not a discretionary reminder, so
-- it isn't user-toggleable the way these seven are.

create table public.user_reminders (
  id uuid primary key default gen_random_uuid(),
  -- Defaults to auth.uid() so a client insert can omit user_id entirely —
  -- confirmed necessary against the real stack: without a default, an
  -- insert that omits user_id sends NULL, and `with check (user_id =
  -- auth.uid())` evaluates NULL = uuid as NULL (not true), so RLS rejects
  -- it with the same generic "violates row-level security policy" error
  -- as an actual cross-user attempt — indistinguishable without this fix.
  user_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  type reminder_type not null,
  is_enabled boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, type)
);

create trigger set_user_reminders_updated_at
  before update on public.user_reminders
  for each row
  execute function public.set_updated_at();

create index idx_user_reminders_user_id on public.user_reminders (user_id);

alter table public.user_reminders enable row level security;

create policy "select own reminders"
  on public.user_reminders for select
  to authenticated
  using (user_id = auth.uid());

create policy "insert own reminders"
  on public.user_reminders for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "update own reminders"
  on public.user_reminders for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "delete own reminders"
  on public.user_reminders for delete
  to authenticated
  using (user_id = auth.uid());

-- Base table-level grants — see the comment in the public_users migration.
grant select, insert, update, delete on public.user_reminders to authenticated;
