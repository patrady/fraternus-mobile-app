-- Seed the Custom event(s), from data/events/custom_events.md. No detail
-- table exists for type = 'custom'. Explicit id so the
-- event_attendees_chapter seed migration can reference this event
-- directly, instead of correlating rows by title.

insert into public.events (id, type, title, description, event_location_id, start_date, end_date)
values (
  '3160bf41-01d8-4c20-abb7-109928f64788',
  'custom',
  'Commitment Ceremony',
  'Fraternus induction ceremony',
  '9f9bae55-a5d9-473f-8eee-79d4da2b18e1',
  '2026-09-22 18:30:00-05',
  '2026-09-22 20:00:00-05'
);
