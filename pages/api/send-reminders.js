
import webpush from 'web-push';
import { supabase } from '@/lib/supabaseClient';

// Configure Web Push with Keys (Server Side)
webpush.setVapidDetails(
    'mailto:grant@example.com', // Your email (required by spec)
    process.env.NEXT_PUBLIC_VAPID_PUBLIC_KEY,
    process.env.VAPID_PRIVATE_KEY
);

export default async function handler(req, res) {
    if (req.method !== 'POST' && req.method !== 'GET') {
        res.status(405).json({ message: 'Method not allowed' });
        return;
    }

    try {
        console.log('--- Starting Reminder Job ---');

        // 1. Get all subscriptions
        const { data: subs, error } = await supabase
            .from('subscriptions')
            .select('*');

        if (error) throw error;
        console.log(`Found ${subs.length} subscriptions.`);

        // 2. (Optional) Filter for users who haven't read today
        // For now, we will just send to everyone to test.

        const payload = JSON.stringify({
            title: 'Bible Tracker',
            body: '⏰ 7pm Reminder: Time to read regarding your streak!',
            icon: '/icons/icon-192x192.png'
        });

        // 3. Send Notifications
        const results = await Promise.allSettled(
            subs.map(sub =>
                webpush.sendNotification(sub.subscription, payload)
                    .catch(async err => {
                        if (err.statusCode === 410 || err.statusCode === 404) {
                            // Subscription is dead (user unsubscribed), delete it
                            console.log(`Cleaning up dead subscription ${sub.id}`);
                            await supabase.from('subscriptions').delete().eq('id', sub.id);
                        }
                        throw err;
                    })
            )
        );

        const successCount = results.filter(r => r.status === 'fulfilled').length;
        const failureCount = results.filter(r => r.status === 'rejected').length;

        console.log(`Sent: ${successCount}, Failed: ${failureCount}`);

        res.status(200).json({ success: true, sent: successCount, failed: failureCount });
    } catch (error) {
        console.error('Reminder Error:', error);
        res.status(500).json({ error: error.message });
    }
}
