-- Seed the Ranch event, from data/events/ranch.md. Source dates are
-- MM-DD-YYYY (07-14-2027), unlike the other event files' ISO format —
-- normalized to YYYY-MM-DD here. Explicit id so the detail-table insert
-- below (and the event_attendees_chapter seed migration) can reference
-- this event directly, instead of correlating rows by title.

insert into public.events (id, type, title, description, event_location_id, start_date, end_date)
values (
  'd852075f-09e4-4922-951a-956649b74dcc',
  'ranch',
  'Ranch 2027',
  'The most epic summer camp ever',
  '80bc249e-bcc1-4b2f-a3b3-a71eb3161925',
  '2027-07-14 12:00:00-05',
  '2027-07-18 10:00:00-05'
);

insert into public.event_ranch_details (event_id, registration_url)
values ('d852075f-09e4-4922-951a-956649b74dcc', 'https://fraternus.org/ranch');
