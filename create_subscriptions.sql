-- Create table to store Web Push Subscriptions
CREATE TABLE IF NOT EXISTS subscriptions (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription jsonb NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- RLS: Users can only manage their own subscriptions
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own subscription"
ON subscriptions FOR INSERT
WITH CHECK ( auth.uid() = user_id );

CREATE POLICY "Users can view own subscription"
ON subscriptions FOR SELECT
USING ( auth.uid() = user_id );

CREATE POLICY "Users can delete own subscription"
ON subscriptions FOR DELETE
USING ( auth.uid() = user_id );

-- IMPORTANT: Service Role (Server) needs to read ALL to send reminders.
-- (Service Role bypasses RLS by default, so no extra policy needed mostly).
