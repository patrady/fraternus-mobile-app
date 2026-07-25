# Fraternus Flutter App

## Goal

This is a flutter application called Fraternus that will be deployed to the iOS and Google app store. It is free.

## Domains

### Authentication

- Auth0 will be used
- Authentication methods include username/password or passkey
- Forget password flow is implemented
- Confirm email flow is implemented

### Profile

- When creating an account, the user must choose between two options: Captain or Guardian. A captain is an adult that is involved with Fraternus (e.g. a mentor/leader). A guardian is an adult that is not personally involved with Fraternus but has a child (or children) in it.
- A user is someone who has an account. A member is someone that is registered with Fraternus (a Brother, Captain, or Commander).
- Brothers cannot sign up for their own account yet. A Guardian creates their Brother's Member record on the Brother's behalf. A future invite flow will let a Brother claim their own account against an existing Member record their Guardian created.
- If it's a Captain signing up: their first name, last name, email, and chapter must be provided. This creates a User, a Member (Role = Captain), and a User Member Association (Relationship = Self).
- If it's a Guardian signing up: their first name, last name, and email must be provided (creates a User only). If the Guardian is also going to Fraternus meetings themselves, a Member record (Role = Captain) is also created for them along with a chapter selection, and a User Member Association (Relationship = Self) is created. Otherwise, the Guardian has no Member record of their own.
- During or after Guardian/Captain signup, Member records for each of their children can be created (Role = Brother). These fields are required for a member: first name, last name, chapter (prefilled based on the Guardian's), and birthday must be provided; email is optional since Brothers may not have one. Each child creation also creates a User Member Association (Relationship = Guardian) linking the Guardian's User Id to the new Member Id. Since these Member records are being created for the first time, there's no need to search for or link an existing Member.
- The chapter will be a drop-down selection from a predefined list. This should be hard coded at first but built in a way later that it can be an API call. Look at the Chapter data model for more information.
- A member can only belong to one chapter
- A user can have a relationship to a member as either Self or Guardian

#### COPPA / Consent

- Any Brother Member under 13 years old (based on Birthday) requires verifiable guardian consent before the Member record is usable (readings, challenges, events, field guide).
- Consent is tracked on the User Member Association row where Relationship = Guardian: Consent Status (Pending, Granted, Revoked), Consent Date, and Consent Method (e.g. email confirmation).
- A Member under 13 with no Association row in Consent Status = Granted is treated as inactive/pending everywhere in the app (no notifications sent, no data entry accepted on their behalf) until consent is granted.
- A Guardian can revoke consent at any time, which should be treated as a request to stop all further data collection for that Member.

### Field Guide

- The field guide is a collection of daily devotionals
- The devotionals are organized by weekly themes that focus on a certain virtue
- A weekly theme will have an overview that lists the virtue, its vice, and its extreme (for example: Virtue: Patience, Vice: Anger, Extreme: Indifference). It also has a few quotes to think about, a reflection, and then short descriptions and common vices for how that virtue plays out with the classic 4 temperaments (choleric, sanguine, melancholic, and phlegmatic)
- Each day a devotional consists of:
    - Identity reading that grounds the user in their identity in Christ
    - Wisdom reading that is a quote
    - Sword (i.e. challenge) that lets the user select from two predefined options
    - Spade (i.e. reflection) where the user notices where the virtue's vice was present throughout the day
    - Closing Prayer reading
- A Guardian or Captain can complete a Field Guide Daily Devotional entry on behalf of a child Member, the same way they can for Challenges and Event RSVPs. The User submitting must have a User Member Association row (Self or Guardian) with that Member.
- Algorithm to determine which devotional is shown:
    - Find where the current date is between the Chapter's Field Guide Details School Year Start Date and School Year End Date
    - Take that record's Field Guide Start Date and calculate how many days it has been since that date using today's date (`days_since_field_guide_start_date`)
    - Find the Field Guide Daily Devotional record where:
        - `Field Guide Daily Devotional`.`Field Guide Week`.`Week Number` = floor(days_since_field_guide_start_date / 7)
        - `Field Guide Daily Devotional`.`Day Number` = days_since_field_guide_start_date mod 7
    - If that record exists, find or create a Field Guide Daily Devotional Member record
    - If that record doesn't exist, show a "you've completed the field guide" screen
- When the user (or their Guardian/Captain on their behalf) selects a sword for the day, populate `Field Guide Daily Devotional Member`.`Sword`, and set `Submitted By User Id` to whoever submitted it
- When the user (or their Guardian/Captain on their behalf) fills in the Spade reflection, populate `Field Guide Daily Devotional Member`.`Spade`, and set `Submitted By User Id` to whoever submitted it
- At the bottom of this page, there should be a checkbox that lets the user mark the day as complete. This sets `Field Guide Daily Devotional Member`.`Completed Date` to the current date
- A notification reminder is sent at the beginning of the day at 7am to tell the user to read today's field guide reading (if it exists)
- A notification reminder is sent at 8pm to tell the user to do their spade reflection and closing prayer for the day (if it exists)
- A streak is shown on the field guide of how many times they have consecutively completed the field guide daily devotional
- There is no bound on how far back a user can retroactively complete a missed day to correct their streak
- A field guide streak resets at the start of each new school year (i.e. each new Chapter Field Guide Details record). This should naturally happen since the field guide will not have content during the summer.

### Challenges

- A challenge is something that is assigned at Frat Night
- A challenge that is tied to the most recent past (non-cancelled) Frat Night remains in effect until the next Frat Night takes place
- The challenge's title is displayed on the page
- A Challenge Member consists of a number of reps of something per week. Examples: take a cold shower 3x this next week, pray the rosary 1x this week, make a morning offering every day this week
- There's a button to display the full description, these are usually very long so it should only be displayed if manually clicked
- If the challenge hasn't been accepted, there's a button to accept the challenge
- Once the challenge has been accepted, the number of reps should be displayed as placeholders with a button for the next available one to be marked as complete. If a rep is complete, it shows as complete with a date in Month, Day (ie August 8th)
- Once all reps are complete, the user is displayed with a congrats screen that shows their streak
- If the challenge is incomplete when the duration ends, the user can still mark reps as complete. This still counts towards their streak.
- There is no bound on how far back a user can retroactively complete a missed challenge to correct their streak
- If the user is a Captain, this tab should display each child they have and have sections for each child's challenge. They should only receive one instance of a notification, not one per child
- A notification is sent the morning after the chapter's Frat Night day of week at 7am introducing the challenge
- A mid-week reminder notification is sent at 7am with how much progress has been made. If the challenge is fully complete, a reminder isn't sent
- A reminder notification is sent the day before the Frat Night day of week at 7am reminding the user to finish the challenge

### Events

- An event will consist of Frat Nights, Excursions, Summer Camp which is called Ranch, HAWC Nights, and other miscellaneous events (fundraising events, adoration, captain meetings, etc.)
- An event has a title, location (optional), description (optional), start time, end time, and attendees (entire chapter, captains only, brothers only, or specific individuals identified by email address)
    - Separate tables will accomplish this instead of one polymorphic table. See Event Attendees Chapter and Event Attendees Specific.
- A captain can RSVP for the event or on behalf of their children (i.e. brothers)
- Reminders are sent 24hrs and 1hr before the event
- No admin tooling is needed yet — Frat Night Templates, Field Guide content, and Events will all be seeded directly into the database to start
- These events will be pulled via an API call
- An event can be added to the user's calendar (either on iOS or android).
- If an event is cancelled, a notification is sent to all eligible attendees whether they RSVPd or not
- A unique constraint is put on Event RSVP (Event Id, Member Id) so if a user changes their RSVP, it doesn't record a change. This happens if a parent RSVPs for their child and their child also has an account and changes the RSVP
- The User (via Submitted By User Id) and Member (via Member Id) must have an association of either Self or Guardian to prevent someone RSVPing for another person
- Do not support recurring events
- There isn't anything preventing a chapter from having the same frat night scheduled for different dates. This allows cancelled frat nights to stay on the calendar and get picked up at a different date.
- The Commander role has no special privileges here
- It is ok that the data model has the Chapter Id on both the "Event Frat Night Details" and "Event Attendees Chapter" tables. Some logic should be written to ensure that these do not deviate.

## Logic

- Streaks
    - A streak is the number of consecutive challenges (or, for the Field Guide, consecutive days) that have been accepted and completed. If a user misses one either because they didn't accept/complete it, the streak restarts
    - Cancelled Frat Nights do not count against a Weekly Challenge streak
    - Late completed challenges or field guide days retroactively apply to the streak, with no limit on how far back this can reach
    - A Field Guide streak resets at the start of each new school year due to challenges not being available during the summer
- Timezones
    - The user's timezone is assumed to be the same time zone as the chapter's location
- Chapters
    - A chapter is open, nothing verifies that a user actually belongs to a specific chapter
- Users and Members
    - A user is anyone that has a login and could be an uninvolved Guardian, an adult Captain/Commander, or (in the future) a Brother
    - A member can be a user, in this case the association would be "Self"; otherwise the association is "Guardian" for a child

## Layout

- The bottom tab navigation will have the following:
    - Field Guide
    - Challenges
    - Events
    - Profile

## Data Models
- User
    - Id
    - First Name
    - Last Name
    - Email
    - Created Date
    - Last Modified Date
- Member
    - Id
    - Chapter Id
    - Role (Brother, Captain, Commander)
    - First Name
    - Last Name
    - Birthday
    - Created Date
    - Last Modified Date
- User Member Association
    - Id
    - User Id
    - Member Id
    - Relationship (Self, Guardian)
    - Consent Status (nullable — Pending, Granted, Revoked; applicable when Relationship = Guardian and the Member is under 13)
    - Consent Date (nullable)
    - Consent Method (nullable)
    - Created Date
    - Last Modified Date
    - Constraints:
        - Unique constraint on (User Id, Member Id)
- Chapter
    - Id
    - Name
    - City
    - State
    - Zip code
    - Timezone (IANA identifier)
    - Church (ex. "St. Philips Catholic Church")
    - Frat Night Day of Week (example: "monday")
    - Frat Night Start Time (ex "19:00")
    - Frat Night End Time (ex "20:30")
    - Frat Night Location
- Chapter Field Guide Details
    - Id
    - Chapter Id
    - School Year Start Date
    - School Year End Date
    - Field Guide Start Date
    - Created Date
    - Last Modified Date
- Frat Night Template
    - Id
    - Title (ex. "the fortitudious man defends his brothers")
    - Description
    - Reading (markdown enabled)
    - Liturgical Day (ie First Sunday in Ordinary Time)
    - start of week calendar date (Ie 2026-01-01)
    - Frat Night Virtue Id
    - Created Date
    - Last Modified Date
    - Constraints:
        - Unique constraint on start of week calendar date
- Frat Night Virtue
    - Id
    - Name (ex justice, prudence, temperance)
- Challenge
    - Id
    - Frat Night Template Id
    - Title
    - Description
    - Duration (number of seconds available to complete the challenge - usually 1w in seconds)
    - Reps (ex 4)
- Challenge Member
    - Id
    - Member Id
    - Challenge Id
    - Committed Date
    - Completed Date
    - Created Date
    - Last Modified Date
- Challenge Member Rep
    - Id
    - Challenge Member Id
    - Completed By User Id
    - Number
    - Created Date
    - Last Modified Date
    - Note: this row is only created once a rep is actually completed — Created Date serves as the completed date, so there is no separate Completed Date field
- Field Guide Week
    - Id
    - Week Number
    - Virtue (i.e. Patience)
    - Vice (i.e. Anger)
    - Extreme (i.e. Indifference)
    - Reflection (markdown enabled)
    - Choleric Application
    - Choleric Vices
    - Sanguine Application
    - Sanguine Vices
    - Melancholic Application
    - Melancholic Vices
    - Phlegmatic Application
    - Phlegmatic Vices
    - Created Date
    - Last Modified Date
    - Constraints:
        - Unique constraint on Week Number
- Field Guide Week Quotes
    - Id
    - Field Guide Week Id
    - Quote
    - Author
    - Created Date
    - Last Modified Date
- Field Guide Daily Devotional
    - Id
    - Field Guide Week Id
    - Day Number
    - Identity Reading
    - Wisdom Quote
    - Wisdom Author
    - Sword Option 1
    - Sword Option 2
    - Spade
    - Closing Prayer
    - Created Date
    - Last Modified Date
- Field Guide Daily Devotional Member
    - Id
    - Field Guide Daily Devotional Id
    - Member Id
    - Submitted By User Id
    - Sword (copied from the selected Sword Option 1 or 2)
    - Spade (free-form text reflection)
    - Completed Date
    - Created Date
    - Last Modified Date
- Event
    - Id
    - Type (any one of the following)
        - frat_night: See Event Frat Night Details
        - excursion: See Event Excursion Details
        - custom
    - Title
    - Description (nullable)
    - Location (nullable)
    - Start Date
    - End Date
    - Cancellation Date (nullable)
    - Created Date
    - Last Modified Date
- Event Frat Night Details
    - Id
    - Event Id
    - Frat Night Template Id
    - Chapter Id
- Event Excursion Details
    - Id
    - Event Id
    - Host Chapter Id
    - Registration Url
- Event Ranch Details
    - Id
    - Event Id
    - Registration Url
- Event Attendees Chapter
    - Id
    - Event Id
    - Chapter Id
    - Role (one of ["Captains", "Brothers", "Chapter"])
- Event Attendees Specific
    - Id
    - Event Id
    - Member Id
- Event RSVP
    - Id
    - Event Id
    - Member Id
    - Submitted By User Id
    - Response (either "Accepted", "Declined", or "Tentative")
    - Created Date
    - Last Modified Date