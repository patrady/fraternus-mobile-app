-- Challenges: 1:1 with a Frat Night Template (reference content), plus the
-- per-Member acceptance/rep-progress tables (user-generated).

create table public.challenges (
  id uuid primary key default gen_random_uuid(),
  frat_night_template_id uuid not null references public.frat_night_templates (id) on delete restrict,
  title text not null,
  description text not null,
  reps integer not null check (reps > 0)
);

alter table public.challenges enable row level security;

create policy "read challenges"
  on public.challenges for select
  to authenticated
  using (true);

grant select on public.challenges to authenticated;

-- User-generated (ADR 0003 cascade target). No row until a Member accepts
-- the challenge — mirrors Event RSVP's "no row until submitted" rule.
create table public.challenge_members (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members (id) on delete cascade,
  challenge_id uuid not null references public.challenges (id) on delete restrict,
  committed_date date not null default current_date,
  completed_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (member_id, challenge_id)
);

create trigger set_challenge_members_updated_at
  before update on public.challenge_members
  for each row
  execute function public.set_updated_at();

create index idx_challenge_members_member_id on public.challenge_members (member_id);
create index idx_challenge_members_challenge_id on public.challenge_members (challenge_id);

alter table public.challenge_members enable row level security;

create policy "select own household challenge progress"
  on public.challenge_members for select
  to authenticated
  using (public.has_member_association(member_id));

-- Accepting a challenge is a plain client insert (no RPC) — mirrors
-- field_guide_daily_devotional_members' upsert pattern. toggle_challenge_rep
-- (see the rpcs migration) is what updates completed_date afterward.
create policy "accept challenge for own household member"
  on public.challenge_members for insert
  to authenticated
  with check (
    public.has_member_association(member_id)
    and public.member_is_write_active(member_id)
  );

-- toggle_challenge_rep runs as the caller (not security definer — see the
-- rpcs migration for why), so its own `update challenge_members` needs
-- this policy to succeed, same as a direct client update would.
create policy "update own household challenge progress"
  on public.challenge_members for update
  to authenticated
  using (public.has_member_association(member_id))
  with check (
    public.has_member_association(member_id)
    and public.member_is_write_active(member_id)
  );

grant select, insert, update on public.challenge_members to authenticated;

-- True if the caller has a Self/Guardian association with the Member that
-- owns target_challenge_member_id. Lives here (not alongside
-- has_member_association in the members_and_associations migration)
-- because it references challenge_members, which doesn't exist until this
-- migration — a real ordering constraint, not just organizational
-- preference.
create or replace function public.has_challenge_member_association(target_challenge_member_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.challenge_members cm
    where cm.id = target_challenge_member_id
      and public.has_member_association(cm.member_id)
  );
$$;

revoke all on function public.has_challenge_member_association(uuid) from public;
grant execute on function public.has_challenge_member_association(uuid) to authenticated;

-- User-generated, transitively cascades from Member via challenge_members
-- (ADR 0003). Only exists once a rep is actually completed — created_at
-- doubles as the completed date, per app_concept.md's note.
create table public.challenge_member_reps (
  id uuid primary key default gen_random_uuid(),
  challenge_member_id uuid not null references public.challenge_members (id) on delete cascade,
  completed_by_user_id uuid references public.users (id) on delete set null,
  number integer not null check (number > 0),
  created_at timestamptz not null default now(),
  unique (challenge_member_id, number)
);

create index idx_challenge_member_reps_challenge_member_id
  on public.challenge_member_reps (challenge_member_id);

alter table public.challenge_member_reps enable row level security;

create policy "select own household reps"
  on public.challenge_member_reps for select
  to authenticated
  using (public.has_challenge_member_association(challenge_member_id));

-- Both gated the same way toggle_challenge_rep checks before ever issuing
-- these statements — defense in depth, same reasoning as everywhere else
-- in this schema.
create policy "insert own household reps"
  on public.challenge_member_reps for insert
  to authenticated
  with check (public.has_challenge_member_association(challenge_member_id));

create policy "delete own household reps"
  on public.challenge_member_reps for delete
  to authenticated
  using (public.has_challenge_member_association(challenge_member_id));

grant select, insert, delete on public.challenge_member_reps to authenticated;
