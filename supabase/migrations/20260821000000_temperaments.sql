-- Temperament Quiz: seeded question/option content (reference, read-only,
-- seeded directly into the database like Frat Night Templates and Field
-- Guide entries — see docs/app_concept.md's Temperaments domain section),
-- and the per-Member result table (user-generated, ADR 0003 cascade
-- target) storing the Primary/Secondary temperament plus the individual
-- answers that produced it. Retaking the quiz overwrites the existing
-- result rather than keeping a history of past attempts.

create type public.temperament_key as enum ('choleric', 'sanguine', 'melancholic', 'phlegmatic');

create table public.temperament_quiz_questions (
  id uuid primary key default gen_random_uuid(),
  question text not null,
  order_number integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (order_number)
);

alter table public.temperament_quiz_questions enable row level security;

create policy "read temperament quiz questions"
  on public.temperament_quiz_questions for select
  to authenticated
  using (true);

create trigger set_temperament_quiz_questions_updated_at
  before update on public.temperament_quiz_questions
  for each row
  execute function public.set_updated_at();

create table public.temperament_quiz_options (
  id uuid primary key default gen_random_uuid(),
  temperament_quiz_question_id uuid not null references public.temperament_quiz_questions (id) on delete cascade,
  text text not null,
  temperament_key public.temperament_key not null,
  order_number integer not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (temperament_quiz_question_id, order_number),
  -- One option per temperament per question — matches the quiz format in
  -- docs/data/temperaments_quiz_questions.md (exactly 4 options, one per key).
  unique (temperament_quiz_question_id, temperament_key)
);

alter table public.temperament_quiz_options enable row level security;

create policy "read temperament quiz options"
  on public.temperament_quiz_options for select
  to authenticated
  using (true);

create trigger set_temperament_quiz_options_updated_at
  before update on public.temperament_quiz_options
  for each row
  execute function public.set_updated_at();

create index idx_temperament_quiz_options_question_id
  on public.temperament_quiz_options (temperament_quiz_question_id);

-- User-generated (ADR 0003 cascade target via member_id). One row per
-- Member — a unique constraint on member_id means retaking the quiz
-- updates this row in place instead of accumulating history.
create table public.member_temperament_results (
  id uuid primary key default gen_random_uuid(),
  member_id uuid not null references public.members (id) on delete cascade,
  submitted_by_user_id uuid references public.users (id) on delete set null,
  primary_temperament_key public.temperament_key not null,
  secondary_temperament_key public.temperament_key not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (member_id),
  check (primary_temperament_key <> secondary_temperament_key)
);

create trigger set_member_temperament_results_updated_at
  before update on public.member_temperament_results
  for each row
  execute function public.set_updated_at();

create index idx_member_temperament_results_member_id
  on public.member_temperament_results (member_id);

-- submitted_by_user_id is always the caller, never client-supplied — same
-- pattern as field_guide_daily_devotional_members.
create trigger set_mtr_submitted_by_user_id
  before insert on public.member_temperament_results
  for each row
  execute function public.set_submitted_by_user_id();

alter table public.member_temperament_results enable row level security;

create policy "select own household temperament result"
  on public.member_temperament_results for select
  to authenticated
  using (public.has_member_association(member_id));

-- save_temperament_quiz_result (below) is what actually writes these rows,
-- but it is deliberately NOT security definer — same reasoning as
-- toggle_challenge_rep — so its own inserts/updates/deletes need these
-- policies to succeed, same as a direct client write would.
create policy "insert own household temperament result"
  on public.member_temperament_results for insert
  to authenticated
  with check (public.has_member_association(member_id));

create policy "update own household temperament result"
  on public.member_temperament_results for update
  to authenticated
  using (public.has_member_association(member_id))
  with check (public.has_member_association(member_id));

-- No delete policy: rows disappear only via cascade from delete_member_data.

-- True if the caller has a Self/Guardian association with the Member that
-- owns target_member_temperament_result_id.
create or replace function public.has_temperament_result_association(target_member_temperament_result_id uuid)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.member_temperament_results mtr
    where mtr.id = target_member_temperament_result_id
      and public.has_member_association(mtr.member_id)
  );
$$;

revoke all on function public.has_temperament_result_association(uuid) from public;
grant execute on function public.has_temperament_result_association(uuid) to authenticated;

-- User-generated, transitively cascades from Member via
-- member_temperament_results (ADR 0003). One row per answered question;
-- save_temperament_quiz_result replaces every row here on a retake.
create table public.member_temperament_result_answers (
  id uuid primary key default gen_random_uuid(),
  member_temperament_result_id uuid not null references public.member_temperament_results (id) on delete cascade,
  temperament_quiz_question_id uuid not null references public.temperament_quiz_questions (id) on delete restrict,
  temperament_quiz_option_id uuid not null references public.temperament_quiz_options (id) on delete restrict,
  created_at timestamptz not null default now(),
  unique (member_temperament_result_id, temperament_quiz_question_id)
);

create index idx_mtra_result_id
  on public.member_temperament_result_answers (member_temperament_result_id);

alter table public.member_temperament_result_answers enable row level security;

create policy "select own household temperament answers"
  on public.member_temperament_result_answers for select
  to authenticated
  using (public.has_temperament_result_association(member_temperament_result_id));

create policy "insert own household temperament answers"
  on public.member_temperament_result_answers for insert
  to authenticated
  with check (public.has_temperament_result_association(member_temperament_result_id));

create policy "delete own household temperament answers"
  on public.member_temperament_result_answers for delete
  to authenticated
  using (public.has_temperament_result_association(member_temperament_result_id));

-- No update policy: a changed answer is a delete + insert (see
-- save_temperament_quiz_result), never an in-place edit.

-- Upserts the Member's result and replaces their answers in one
-- transaction. Deliberately NOT security definer, matching
-- toggle_challenge_rep: everything this touches is data the caller already
-- has an association for, so running as the caller and relying on the
-- table RLS policies above is correct — defense in depth, not a
-- workaround. p_answers is an array of {"question_id": uuid, "option_id":
-- uuid} objects, one per answered question.
create or replace function public.save_temperament_quiz_result(
  p_member_id uuid,
  p_primary_key public.temperament_key,
  p_secondary_key public.temperament_key,
  p_answers jsonb
)
returns public.member_temperament_results
language plpgsql
set search_path = public
as $$
declare
  v_result public.member_temperament_results;
begin
  if not public.has_member_association(p_member_id) then
    raise exception 'not authorized' using errcode = '42501';
  end if;

  insert into public.member_temperament_results (member_id, primary_temperament_key, secondary_temperament_key)
  values (p_member_id, p_primary_key, p_secondary_key)
  on conflict (member_id) do update
    set primary_temperament_key = excluded.primary_temperament_key,
        secondary_temperament_key = excluded.secondary_temperament_key
  returning * into v_result;

  delete from public.member_temperament_result_answers
  where member_temperament_result_id = v_result.id;

  insert into public.member_temperament_result_answers (member_temperament_result_id, temperament_quiz_question_id, temperament_quiz_option_id)
  select v_result.id, (answer->>'question_id')::uuid, (answer->>'option_id')::uuid
  from jsonb_array_elements(p_answers) as answer;

  return v_result;
end;
$$;

grant execute on function public.save_temperament_quiz_result(uuid, public.temperament_key, public.temperament_key, jsonb) to authenticated;

grant select on public.temperament_quiz_questions to authenticated;
grant select on public.temperament_quiz_options to authenticated;
grant select, insert, update on public.member_temperament_results to authenticated;
grant select, insert, delete on public.member_temperament_result_answers to authenticated;
