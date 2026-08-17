-- FCM device tokens — infrastructure, not domain data, so not in
-- app_concept.md's Data Models. Upserted from the Flutter app on launch and
-- on FirebaseMessaging.onTokenRefresh (see lib/features/notifications/).

create table public.user_devices (
  id uuid primary key default gen_random_uuid(),
  -- default auth.uid() — see the longer note on this in the user_reminders
  -- migration; same reasoning applies to every client-direct-insert table.
  user_id uuid not null default auth.uid() references public.users (id) on delete cascade,
  fcm_token text not null unique,
  platform text not null, -- 'ios' | 'android'
  created_at timestamptz not null default now()
);

create index idx_user_devices_user_id on public.user_devices (user_id);

alter table public.user_devices enable row level security;

create policy "select own devices"
  on public.user_devices for select
  to authenticated
  using (user_id = auth.uid());

create policy "insert own devices"
  on public.user_devices for insert
  to authenticated
  with check (user_id = auth.uid());

create policy "delete own devices"
  on public.user_devices for delete
  to authenticated
  using (user_id = auth.uid());

-- No update policy: a token doesn't get edited, only replaced (delete +
-- insert) or removed on sign-out.

grant select, insert, delete on public.user_devices to authenticated;

-- The event-cancellation Edge Function (service_role) reads every eligible
-- member's device tokens across households — a plain "select own" policy
-- wouldn't cover that, and this table has no per-Member scoping to hang a
-- has_member_association()-style policy off anyway (it's User-scoped, and
-- the notified Users are households other than the one cancelling).
-- service_role's BYPASSRLS attribute is the correct trust boundary here:
-- only trusted server-side code reads across households, never the client.
-- BYPASSRLS skips policy checks but is not a substitute for a table grant,
-- though — service_role needs this SELECT explicitly, same as any other
-- role (see the longer note on this in the members_and_associations
-- migration, where it was first confirmed against the real local stack).
grant select on public.user_devices to service_role;
