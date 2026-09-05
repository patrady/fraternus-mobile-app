-- Field Guide: weekly theme content, daily devotional content (reference,
-- read-only), and the per-Member completion table (user-generated, the
-- POC's chosen CRUD vertical slice per
-- docs/adrs/002_supabase_backend_poc.md's suggested resource).

create table public.field_guide_weeks (
  id uuid primary key default gen_random_uuid(),
  -- Which program year this week's content belongs to. Organizational
  -- metadata only — the devotional-lookup algorithm (see
  -- get_field_guide_devotional_for_date below) keys off week_number alone,
  -- which stays globally unique across the whole curriculum.
  year_number integer not null,
  week_number integer not null unique,
  virtue text not null,
  vice text not null,
  extreme text not null,
  reflection text not null, -- markdown
  choleric_application text not null,
  choleric_vices text not null,
  sanguine_application text not null,
  sanguine_vices text not null,
  melancholic_application text not null,
  melancholic_vices text not null,
  phlegmatic_application text not null,
  phlegmatic_vices text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.field_guide_weeks enable row level security;

create policy "read field guide weeks"
  on public.field_guide_weeks for select
  to authenticated
  using (true);

create trigger set_field_guide_weeks_updated_at
  before update on public.field_guide_weeks
  for each row
  execute function public.set_updated_at();

-- Links a Frat Night Template to the Field Guide Week whose daily
-- devotionals run for the 7 days starting on whichever Event references
-- that template (see get_field_guide_devotional_for_date in
-- 20260817172600_field_guide_frat_night_rpcs.sql — day 1 of the week is
-- literally that Event's start_date, not a separately configured
-- school-year offset). Added here (not in reference_content.sql, where
-- frat_night_templates is created) since this table doesn't exist yet at
-- that point in migration order.
--
-- Nullable: not every Frat Night Template has daily devotional content —
-- e.g. Rush Night templates run before the Field Guide curriculum begins,
-- and simply show no current devotional for that week.
alter table public.frat_night_templates
  add column field_guide_week_id uuid references public.field_guide_weeks (id) on delete restrict;

create table public.field_guide_week_quotes (
  id uuid primary key default gen_random_uuid(),
  field_guide_week_id uuid not null references public.field_guide_weeks (id) on delete cascade,
  quote text not null,
  author text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.field_guide_week_quotes enable row level security;

create policy "read field guide week quotes"
  on public.field_guide_week_quotes for select
  to authenticated
  using (true);

create trigger set_field_guide_week_quotes_updated_at
  before update on public.field_guide_week_quotes
  for each row
  execute function public.set_updated_at();

create index idx_field_guide_week_quotes_week_id on public.field_guide_week_quotes (field_guide_week_id);

create table public.field_guide_daily_devotionals (
  id uuid primary key default gen_random_uuid(),
  field_guide_week_id uuid not null references public.field_guide_weeks (id) on delete cascade,
  -- 1-7, Monday-anchored (matches DateTime.weekday) — see the plan's note
  -- on the discrepancy with app_concept.md's literal "mod 7" (0-6) prose.
  day_number integer not null check (day_number between 1 and 7),
  identity_reading text not null,
  wisdom_quote text not null,
  wisdom_author text not null,
  sword_option_1 text not null,
  sword_option_2 text not null,
  -- The day's reflection *prompt* — disambiguated from
  -- field_guide_daily_devotional_members.spade, the member's own answer.
  spade_prompt text not null,
  closing_prayer text not null,
  closing_prayer_author text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (field_guide_week_id, day_number)
);

alter table public.field_guide_daily_devotionals enable row level security;

create policy "read field guide daily devotionals"
  on public.field_guide_daily_devotionals for select
  to authenticated
  using (true);

create trigger set_field_guide_daily_devotionals_updated_at
  before update on public.field_guide_daily_devotionals
  for each row
  execute function public.set_updated_at();

create index idx_field_guide_daily_devotionals_week_id
  on public.field_guide_daily_devotionals (field_guide_week_id);

-- User-generated: one row per (devotional, member) completion. ADR 0003
-- cascade target — deleting a Member deletes every row here for them.
create table public.field_guide_daily_devotional_members (
  id uuid primary key default gen_random_uuid(),
  daily_devotional_id uuid not null references public.field_guide_daily_devotionals (id) on delete restrict,
  member_id uuid not null references public.members (id) on delete cascade,
  submitted_by_user_id uuid references public.users (id) on delete set null,
  sword text,
  spade text,
  completed_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (daily_devotional_id, member_id)
);

create trigger set_field_guide_daily_devotional_members_updated_at
  before update on public.field_guide_daily_devotional_members
  for each row
  execute function public.set_updated_at();

create index idx_fgddm_daily_devotional_id
  on public.field_guide_daily_devotional_members (daily_devotional_id);
create index idx_fgddm_member_id
  on public.field_guide_daily_devotional_members (member_id);

-- submitted_by_user_id is always the caller, never client-supplied — same
-- pattern used by submit_event_rsvp/toggle_challenge_rep once those exist.
create or replace function public.set_submitted_by_user_id()
returns trigger
language plpgsql
as $$
begin
  new.submitted_by_user_id = auth.uid();
  return new;
end;
$$;

create trigger set_fgddm_submitted_by_user_id
  before insert on public.field_guide_daily_devotional_members
  for each row
  execute function public.set_submitted_by_user_id();

alter table public.field_guide_daily_devotional_members enable row level security;

create policy "select own household devotional completions"
  on public.field_guide_daily_devotional_members for select
  to authenticated
  using (public.has_member_association(member_id));

create policy "insert own household devotional completions"
  on public.field_guide_daily_devotional_members for insert
  to authenticated
  with check (public.has_member_association(member_id));

create policy "update own household devotional completions"
  on public.field_guide_daily_devotional_members for update
  to authenticated
  using (public.has_member_association(member_id))
  with check (public.has_member_association(member_id));

-- No delete policy: rows disappear only via cascade from delete_member_data.

-- Base table-level grants — see the comment in the public_users migration
-- for why these are necessary in addition to the RLS policies above. The
-- two non-security-definer RPCs in the next migration
-- (get_field_guide_devotional_for_date, get_field_guide_streak) run as the
-- calling role too, so they depend on these same SELECT grants.
grant select on public.field_guide_weeks to authenticated;
grant select on public.field_guide_week_quotes to authenticated;
grant select on public.field_guide_daily_devotionals to authenticated;
grant select, insert, update on public.field_guide_daily_devotional_members to authenticated;
