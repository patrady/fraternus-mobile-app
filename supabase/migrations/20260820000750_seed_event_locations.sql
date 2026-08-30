-- Seed Event Locations, from data/events/event_locations.md. Explicit ids
-- so the events seed migrations below (frat nights, excursions, ranch,
-- custom) can reference them directly via event_location_id.

insert into public.event_locations (id, name, street, city, state, zip_code)
values
  ('9f9bae55-a5d9-473f-8eee-79d4da2b18e1', 'St. Philips Catholic Church', '113 2nd Ave S', 'Franklin', 'TN', '37064'),
  ('21a88317-9fd8-4b96-8c2f-784092b24c78', 'David Crocket State Park', '1400 W Gaines St', 'Lawrenceburg', 'TN', '38464'),
  ('ae8c3c8e-9346-417a-95a0-72057fb14eda', 'Camp Woodlee', '273 Clendenon Ln', 'McMinnville', 'TN', '37110'),
  ('d4aea776-6fb9-4970-8a4e-deee59bc3c07', 'Eagle Ridge Retreat Center', '8744 Barren River Rd', 'Bowling Green', 'KY', '42101'),
  ('135d9c0d-93ac-4166-86d5-d53d4834634a', 'Andrews Spring Farm', '1452 New Columbia Hwy', 'Lewisburg', 'TN', '37091'),
  ('80bc249e-bcc1-4b2f-a3b3-a71eb3161925', 'Ocoee Ridge Camp', '479 Frey Road', 'Old Fort', 'TN', '37362');
