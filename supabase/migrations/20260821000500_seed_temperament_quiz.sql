-- Seeds the 24 Temperament Quiz questions and their 96 options (4 per
-- question, one per temperament), transcribed verbatim from
-- docs/data/temperaments_quiz_questions.md — same source the app's
-- StaticTemperamentQuizRepository was hardcoded from
-- (fraternus_mobile_app/lib/features/guide/data/temperament_quiz_repository.dart).
-- Option order within each question is fixed choleric/sanguine/melancholic/
-- phlegmatic (A/B/C/D in the doc), matching the doc's scoring assumption.
--
-- Correlates the questions insert to the options insert by order_number
-- (unique per temperament_quiz_questions), same pattern as
-- 20260820003500_seed_field_guide_weeks.sql.

with inserted_questions as (
  insert into public.temperament_quiz_questions (question, order_number)
  values
    ('When something goes wrong on a project I''m leading, I usually:', 1),
    ('In a group conversation, I tend to:', 2),
    ('My natural pace of getting things done is:', 3),
    ('When I''m criticized, my first reaction is usually to:', 4),
    ('My room or workspace is usually:', 5),
    ('When I set a goal, I''m most motivated by:', 6),
    ('If a friend is late to meet me, I probably:', 7),
    ('My sense of humor is best described as:', 8),
    ('When making a decision, I rely most on:', 9),
    ('In a group project, I naturally become:', 10),
    ('My emotions tend to:', 11),
    ('When I fail at something, I''m most likely to:', 12),
    ('My ideal weekend involves:', 13),
    ('When someone challenges my opinion, I:', 14),
    ('My friends would probably describe me as:', 15),
    ('When I have a lot to do, I:', 16),
    ('In new or unfamiliar situations, I usually feel:', 17),
    ('When I''m wronged by someone, forgiveness for me is:', 18),
    ('My work style is best described as:', 19),
    ('When plans change last minute, I:', 20),
    ('What I struggle with most is:', 21),
    ('In prayer or quiet reflection, I tend toward:', 22),
    ('When I see someone struggling, my instinct is to:', 23),
    ('If I''m honest, what drives most of my choices is:', 24)
  returning id, order_number
)
insert into public.temperament_quiz_options (temperament_quiz_question_id, text, temperament_key, order_number)
select q.id, o.text, o.temperament_key::public.temperament_key, o.choice_order
from inserted_questions q
join (
  values
    (1, 'Take charge immediately and start fixing it.', 'choleric', 1),
    (1, 'Make a joke to lighten the mood, then figure it out.', 'sanguine', 2),
    (1, 'Quietly analyze what went wrong before doing anything.', 'melancholic', 3),
    (1, 'Wait to see if it resolves itself or someone else steps in.', 'phlegmatic', 4),

    (2, 'Do most of the talking and steer the topic.', 'choleric', 1),
    (2, 'Bounce energetically between several topics.', 'sanguine', 2),
    (2, 'Listen closely and speak only when I have something considered to add.', 'melancholic', 3),
    (2, 'Stay quiet unless directly asked something.', 'phlegmatic', 4),

    (3, 'Fast and decisive — I''ll adjust course later if needed.', 'choleric', 1),
    (3, 'Fast but easily distracted by something more interesting.', 'sanguine', 2),
    (3, 'Slow and careful — I want it right the first time.', 'melancholic', 3),
    (3, 'Slow and steady — no rush, no stress.', 'phlegmatic', 4),

    (4, 'Push back or defend my position.', 'choleric', 1),
    (4, 'Feel bad for a moment, then move on quickly.', 'sanguine', 2),
    (4, 'Take it hard and think about it for a long time.', 'melancholic', 3),
    (4, 'Not react much outwardly, even if I mind it inside.', 'phlegmatic', 4),

    (5, 'Organized around whatever project I''m currently driving.', 'choleric', 1),
    (5, 'A little chaotic — lots going on at once.', 'sanguine', 2),
    (5, 'Neat and deliberately arranged.', 'melancholic', 3),
    (5, 'Simple and uncluttered, not because I planned it that way.', 'phlegmatic', 4),

    (6, 'Winning, achieving, or being the best.', 'choleric', 1),
    (6, 'The fun of doing it with other people.', 'sanguine', 2),
    (6, 'Doing it in a way I can be proud of, meeting a high standard.', 'melancholic', 3),
    (6, 'Not disrupting my peace too much to get there.', 'phlegmatic', 4),

    (7, 'Get annoyed and think about how to avoid this next time.', 'choleric', 1),
    (7, 'Barely notice — I got distracted by something else while waiting.', 'sanguine', 2),
    (7, 'Assume something''s wrong and start worrying.', 'melancholic', 3),
    (7, 'Wait patiently without much thought about it.', 'phlegmatic', 4),

    (8, 'Sharp, sarcastic, or competitive.', 'choleric', 1),
    (8, 'Playful, silly, loves to entertain.', 'sanguine', 2),
    (8, 'Dry, subtle, or a little dark.', 'melancholic', 3),
    (8, 'Easygoing — I laugh more than I joke.', 'phlegmatic', 4),

    (9, 'My gut, and I move fast.', 'choleric', 1),
    (9, 'What feels exciting or fun in the moment.', 'sanguine', 2),
    (9, 'A careful weighing of pros, cons, and long-term consequences.', 'melancholic', 3),
    (9, 'Whatever keeps things simple and avoids conflict.', 'phlegmatic', 4),

    (10, 'The one giving direction, whether asked to or not.', 'choleric', 1),
    (10, 'The one keeping morale and energy up.', 'sanguine', 2),
    (10, 'The one catching mistakes others miss.', 'melancholic', 3),
    (10, 'The one who does their part without needing recognition.', 'phlegmatic', 4),

    (11, 'Flare up quickly and burn out fast.', 'choleric', 1),
    (11, 'Shift quickly with whatever''s happening around me.', 'sanguine', 2),
    (11, 'Build slowly but last a long time.', 'melancholic', 3),
    (11, 'Stay level most of the time.', 'phlegmatic', 4),

    (12, 'Get frustrated, then immediately try again.', 'choleric', 1),
    (12, 'Feel down briefly, then get distracted by something new.', 'sanguine', 2),
    (12, 'Replay it in my head for days.', 'melancholic', 3),
    (12, 'Shrug it off without much internal disturbance.', 'phlegmatic', 4),

    (13, 'Accomplishing something significant.', 'choleric', 1),
    (13, 'Being around people, doing something spontaneous.', 'sanguine', 2),
    (13, 'Quiet time to think, read, or work on something meaningful alone.', 'melancholic', 3),
    (13, 'Relaxing with no particular agenda.', 'phlegmatic', 4),

    (14, 'Argue my case firmly, sometimes bluntly.', 'choleric', 1),
    (14, 'Go along with it to keep things friendly, even if I disagree inside.', 'sanguine', 2),
    (14, 'Get quietly hurt or defensive but stay composed outwardly.', 'melancholic', 3),
    (14, 'Don''t feel much need to defend it either way.', 'phlegmatic', 4),

    (15, 'Driven, intense, a natural leader.', 'choleric', 1),
    (15, 'Fun, outgoing, the life of the group.', 'sanguine', 2),
    (15, 'Thoughtful, deep, sometimes hard to read.', 'melancholic', 3),
    (15, 'Calm, easy to get along with, low-drama.', 'phlegmatic', 4),

    (16, 'Charge through it, sometimes impatient with obstacles.', 'choleric', 1),
    (16, 'Get through the fun parts first and put off the boring parts.', 'sanguine', 2),
    (16, 'Make a careful plan before starting anything.', 'melancholic', 3),
    (16, 'Do it at a steady pace, no particular urgency.', 'phlegmatic', 4),

    (17, 'Eager to take control and figure it out.', 'choleric', 1),
    (17, 'Excited and curious to meet new people.', 'sanguine', 2),
    (17, 'Cautious and want to observe before participating.', 'melancholic', 3),
    (17, 'Content to follow along and adapt as I go.', 'phlegmatic', 4),

    (18, 'Quick — I get angry fast but don''t hold grudges long.', 'choleric', 1),
    (18, 'Easy — I forget about it pretty quickly.', 'sanguine', 2),
    (18, 'Hard — I tend to relive it and it takes a while to let go.', 'melancholic', 3),
    (18, 'Simple — it rarely bothers me enough to hold onto.', 'phlegmatic', 4),

    (19, 'Efficient and results-focused, sometimes impatient with process.', 'choleric', 1),
    (19, 'Creative and energetic, but inconsistent with follow-through.', 'sanguine', 2),
    (19, 'Meticulous and thorough, sometimes slow to finish because I want it perfect.', 'melancholic', 3),
    (19, 'Reliable and consistent, without much need for excitement.', 'phlegmatic', 4),

    (20, 'Get frustrated but adapt fast and move on.', 'choleric', 1),
    (20, 'Roll with it — new plan sounds fun too.', 'sanguine', 2),
    (20, 'Feel unsettled — I prefer to know what to expect.', 'melancholic', 3),
    (20, 'Don''t mind much either way.', 'phlegmatic', 4),

    (21, 'Being too blunt, impatient, or controlling.', 'choleric', 1),
    (21, 'Being unreliable, distracted, or overly talkative.', 'sanguine', 2),
    (21, 'Overthinking, being too critical of myself or others, or melancholy.', 'melancholic', 3),
    (21, 'Being too passive, indecisive, or unmotivated.', 'phlegmatic', 4),

    (22, 'Short, focused, goal-oriented prayer — I want to get back to doing something.', 'choleric', 1),
    (22, 'Prayer that''s easily distracted unless something engages me emotionally.', 'sanguine', 2),
    (22, 'Deep, extended reflection — I could sit with it for a long time.', 'melancholic', 3),
    (22, 'Simple, steady prayer without much internal turbulence.', 'phlegmatic', 4),

    (23, 'Jump in and fix the problem for them.', 'choleric', 1),
    (23, 'Cheer them up and distract them from it.', 'sanguine', 2),
    (23, 'Sit with them and take their pain seriously.', 'melancholic', 3),
    (23, 'Offer quiet, steady support without making a big deal of it.', 'phlegmatic', 4),

    (24, 'A desire to achieve, win, or be in control.', 'choleric', 1),
    (24, 'A desire for enjoyment, connection, and approval.', 'sanguine', 2),
    (24, 'A desire to do things well and understand things deeply.', 'melancholic', 3),
    (24, 'A desire for peace and to avoid unnecessary conflict.', 'phlegmatic', 4)
) as o(order_number, text, temperament_key, choice_order)
on o.order_number = q.order_number;
