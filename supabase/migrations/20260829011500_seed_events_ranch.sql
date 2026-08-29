-- Seed the Ranch event, from data/events/ranch.md. Source dates are
-- MM-DD-YYYY (07-14-2027), unlike the other event files' ISO format —
-- normalized to YYYY-MM-DD here.

with new_events as (
  insert into public.events (type, title, description, location, start_date, end_date)
  values (
    'ranch',
    'Ranch 2027',
    'The most epic summer camp ever',
    'Ocoee Ridge Camp, 479 Frey Road, Old Fort, TN',
    '2027-07-14 12:00:00-06',
    '2027-07-18 10:00:00-06'
  )
  returning id, title
)
insert into public.event_ranch_details (event_id, registration_url)
select id, 'https://fraternus.org/ranch'
from new_events
where title = 'Ranch 2027';
