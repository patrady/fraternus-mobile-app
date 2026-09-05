-- Custom RPC endpoints for Phase 3 (the Field Guide CRUD slice) plus the
-- two signup-completion functions every signup path depends on. See the
-- implementation plan §4 for the full endpoint catalog and rationale —
-- default to plain PostgREST for straightforward reads, RPC only for real
-- logic (date-math, atomicity, server-side validation).
--
-- get_field_guide_devotional_for_date/get_field_guide_streak (originally
-- #1/#2 here) now live in 20260817172600_field_guide_frat_night_rpcs.sql —
-- they resolve content off the chapter's Frat Night events, so they can't
-- be defined until public.events/event_frat_night_details exist, which
-- isn't until the events migration, after this one.

-- 9. Atomically creates a Brother Member + Guardian association (+ Granted
-- consent if under 13), for the currently-authenticated Guardian. Replaces
-- the client doing a two-step Member-then-Association write, which would
-- otherwise need its own transaction handling on the client side.
--
-- Consent is auto-granted rather than left Pending: real verified
-- parental consent is a separate, not-yet-designed flow (see
-- SUPABASE_MIGRATION_TODO.md's "Consent-granting verification flow" item)
-- and nothing today ever moves a Pending row to Granted, which would make
-- every under-13 child permanently write-blocked. Revisit this once that
-- verification flow exists — a Guardian will need to explicitly grant
-- (not have it assumed) at that point.
create or replace function public.create_child_member(
  p_first_name text,
  p_last_name text,
  p_chapter_key text,
  p_birthday date,
  p_email text default null
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_member_id uuid;
  v_requires_consent boolean;
begin
  insert into public.members (chapter_key, role, first_name, last_name, birthday, email)
  values (p_chapter_key, 'brother', p_first_name, p_last_name, p_birthday, p_email)
  returning id into v_member_id;

  v_requires_consent := extract(year from age(current_date, p_birthday)) < 13;

  insert into public.user_member_associations (
    user_id, member_id, relationship, consent_status, consent_date, consent_method
  )
  values (
    auth.uid(),
    v_member_id,
    'guardian',
    case when v_requires_consent then 'granted'::consent_status else null end,
    case when v_requires_consent then now() else null end,
    case when v_requires_consent then 'auto-granted at signup (verification flow not yet built)' else null end
  );

  return v_member_id;
end;
$$;

revoke all on function public.create_child_member(text, text, text, date, text) from public;
grant execute on function public.create_child_member(text, text, text, date, text) to authenticated;

-- 10. Atomically creates a Captain Member + Self association for the
-- currently-authenticated user. Used by both signup branches that create a
-- Captain-role Member for themselves — a Captain signing up directly, and
-- a Guardian who also attends meetings (see app_concept.md's Profile
-- section; nothing about this RPC is Captain-signup-specific beyond name).
create or replace function public.complete_captain_signup(
  p_chapter_key text,
  p_first_name text,
  p_last_name text,
  p_birthday date
) returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_member_id uuid;
begin
  insert into public.members (chapter_key, role, first_name, last_name, birthday, email)
  select p_chapter_key, 'captain', p_first_name, p_last_name, p_birthday, u.email
  from public.users u
  where u.id = auth.uid()
  returning id into v_member_id;

  insert into public.user_member_associations (user_id, member_id, relationship)
  values (auth.uid(), v_member_id, 'self');

  return v_member_id;
end;
$$;

revoke all on function public.complete_captain_signup(text, text, text, date) from public;
grant execute on function public.complete_captain_signup(text, text, text, date) to authenticated;
