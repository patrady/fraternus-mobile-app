// Fires when an Event's cancellation_date transitions from null to
// non-null (see the `on_event_cancelled` trigger in the events migration).
// Per app_concept.md: "If an event is cancelled, a notification is sent to
// all eligible attendees whether they RSVPd or not" — this is the one
// reminder type that fundamentally cannot be done on-device (the reason
// ADR 0001 §5 originally deferred it), which is why it's the POC's chosen
// server-triggered reminder path (ADR 0002 §7 / plan §9) instead of one of
// the six time-based types.
//
// Setup this function needs before it can actually deliver a push (none of
// which this code can supply on its own):
//   1. A Firebase project, with Cloud Messaging enabled.
//   2. A service account with the "Firebase Cloud Messaging API" role;
//      download its JSON key.
//   3. `supabase secrets set FCM_SERVICE_ACCOUNT_JSON='<the JSON, as one line>'`
//   4. `supabase secrets set FCM_PROJECT_ID='<the Firebase project id>'`
//   5. `supabase secrets set WEBHOOK_SECRET='<any random string>'` — must
//      match the `X-Webhook-Secret` header the DB trigger sends (see the
//      events migration's `on_event_cancelled` trigger).
//   6. iOS additionally needs an APNs auth key uploaded to the Firebase
//      project (Project Settings > Cloud Messaging > Apple app config)
//      before iOS devices can receive pushes at all — this is configured
//      in the Firebase console, not in code.

import { createClient } from 'jsr:@supabase/supabase-js@2';
import { GoogleAuth } from 'npm:google-auth-library@9';

interface DatabaseWebhookPayload {
  type: 'INSERT' | 'UPDATE' | 'DELETE';
  table: string;
  schema: string;
  record: Record<string, unknown>;
  old_record: Record<string, unknown> | null;
}

Deno.serve(async (req) => {
  try {
    return await handleRequest(req);
  } catch (error) {
    // Without this, an uncaught throw (e.g. missing FCM credentials) falls
    // through to the Deno runtime's own opaque 500 — confirmed against a
    // real invocation, where the actual cause only showed up in `supabase
    // functions serve` logs, not the HTTP response. Callers (and whoever's
    // debugging this later) should see the real reason without needing log
    // access.
    return Response.json({ error: error instanceof Error ? error.message : String(error) }, { status: 500 });
  }
});

async function handleRequest(req: Request): Promise<Response> {
  const webhookSecret = Deno.env.get('WEBHOOK_SECRET');
  if (!webhookSecret || req.headers.get('X-Webhook-Secret') !== webhookSecret) {
    return new Response('Unauthorized', { status: 401 });
  }

  const payload = (await req.json()) as DatabaseWebhookPayload;

  const wasCancelledJustNow =
    payload.old_record?.cancellation_date == null && payload.record.cancellation_date != null;
  if (!wasCancelledJustNow) {
    // Trigger's WHEN clause should already prevent this, but the check
    // costs nothing and makes the function safe to invoke directly too.
    return Response.json({ skipped: 'not a cancellation transition' });
  }

  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);

  const eventId = payload.record.id as string;
  const eventTitle = payload.record.title as string;

  const { data: eligibleRows, error: eligibleError } = await supabase.rpc('get_all_event_eligible_members', {
    p_event_id: eventId,
  });
  if (eligibleError) return Response.json({ error: eligibleError.message }, { status: 500 });

  const memberIds = (eligibleRows ?? []).map((row: { member_id: string }) => row.member_id);
  if (memberIds.length === 0) return Response.json({ notified: 0 });

  // Resolve Members -> the Users responsible for them (Self or Guardian),
  // deduped — ADR 0001 §5's per-User dedup rule: one push per household,
  // not one per eligible child.
  const { data: associations, error: assocError } = await supabase
    .from('user_member_associations')
    .select('user_id')
    .in('member_id', memberIds);
  if (assocError) return Response.json({ error: assocError.message }, { status: 500 });

  const userIds = [...new Set((associations ?? []).map((row: { user_id: string }) => row.user_id as string))];
  if (userIds.length === 0) return Response.json({ notified: 0 });

  const { data: devices, error: devicesError } = await supabase
    .from('user_devices')
    .select('fcm_token')
    .in('user_id', userIds);
  if (devicesError) return Response.json({ error: devicesError.message }, { status: 500 });

  const tokens = (devices ?? []).map((row: { fcm_token: string }) => row.fcm_token as string);
  if (tokens.length === 0) return Response.json({ notified: 0 });

  const accessToken = await getFcmAccessToken();
  const projectId = Deno.env.get('FCM_PROJECT_ID')!;

  const sendResults = await Promise.allSettled(
    tokens.map((token) =>
      fetch(`https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${accessToken}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: {
            token,
            notification: { title: 'Event Cancelled', body: `${eventTitle} has been cancelled.` },
          },
        }),
      }),
    ),
  );
  const failures = sendResults.filter((r) => r.status === 'rejected').length;

  return Response.json({ notified: tokens.length - failures, failed: failures });
}

async function getFcmAccessToken(): Promise<string> {
  const serviceAccountJson = Deno.env.get('FCM_SERVICE_ACCOUNT_JSON');
  if (!serviceAccountJson) {
    throw new Error(
      'FCM_SERVICE_ACCOUNT_JSON secret is not configured — see the setup steps in this file\'s header comment.',
    );
  }
  const auth = new GoogleAuth({
    credentials: JSON.parse(serviceAccountJson),
    scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
  });
  const client = await auth.getClient();
  const { token } = await client.getAccessToken();
  if (!token) throw new Error('Failed to obtain an FCM access token from the service account credentials.');
  return token;
}
