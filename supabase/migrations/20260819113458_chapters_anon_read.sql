-- Chapter selection happens on the Guardian/Captain signup screens before
-- any session exists (the SelectField is populated and chosen from while
-- filling out the form, well before auth.signUp() runs) — so unlike the
-- rest of reference_content, this one table also needs to be readable by
-- the anon role. Chapters are non-sensitive public directory data (name,
-- city, meeting time/location), so this is safe to widen.

drop policy "read chapters" on public.chapters;

create policy "read chapters"
  on public.chapters for select
  to anon, authenticated
  using (true);

grant select on public.chapters to anon;
