const ONESIGNAL_API_URL = 'https://api.onesignal.com/notifications'

export async function sendOneSignalPushNotification(
  userId: string,
  title: string,
  body: string,
  data?: Record<string, string>,
): Promise<{ skipped: boolean; id?: string }> {
  const appId = process.env.ONESIGNAL_APP_ID
  const apiKey = process.env.ONESIGNAL_REST_API_KEY
  if (!appId || !apiKey || !userId) return { skipped: true }

  const response = await fetch(ONESIGNAL_API_URL, {
    method: 'POST',
    headers: {
      Authorization: `Basic ${apiKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      app_id: appId,
      include_aliases: { external_id: [userId] },
      target_channel: 'push',
      headings: { en: title },
      contents: { en: body },
      data: data || {},
    }),
  })

  if (!response.ok) {
    const text = await response.text().catch(() => '')
    throw new Error(`OneSignal push failed: ${response.status} ${text}`)
  }

  const payload = await response.json().catch(() => ({}))
  return { skipped: false, id: payload?.id }
}
