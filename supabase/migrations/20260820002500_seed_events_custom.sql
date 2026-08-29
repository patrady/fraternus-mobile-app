-- Seed the Custom event(s), from data/events/custom_events.md. No detail
-- table exists for type = 'custom'.

insert into public.events (type, title, description, location, start_date, end_date)
values (
  'custom',
  'Commitment Ceremony',
  'Fraternus induction ceremony',
  'St. Philips Catholic Church',
  '2026-09-22 18:30:00-06',
  '2026-09-22 20:00:00-06'
);
