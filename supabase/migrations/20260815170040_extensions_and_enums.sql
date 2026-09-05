-- Extensions, shared enum types, and the shared updated_at trigger function
-- used by every table in this schema. See docs/adrs/002_supabase_backend_poc.md
-- and docs/app_concept.md for the schema this implements.

create extension if not exists pgcrypto;

create type member_role as enum ('brother', 'captain', 'commander');
create type association_relationship as enum ('self', 'guardian');
create type event_type as enum ('frat_night', 'excursion', 'ranch', 'custom', 'commitment_ceremony', 'ceremony');
create type event_attendee_chapter_role as enum ('captains', 'brothers', 'chapter');
create type rsvp_response as enum ('accepted', 'declined', 'tentative');
create type reminder_type as enum (
  'field_guide_morning',
  'field_guide_evening',
  'new_challenge',
  'challenge_mid_week',
  'challenge_last_day',
  'event_24hr',
  'event_1hr'
);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
