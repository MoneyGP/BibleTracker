-- Create a trigger to automatically create a profile entry when a new user signs up via Supabase Auth.
-- This ensures the foreign key relation in 'posts' (which points to profiles) always has a valid target.

-- 1. Create the function
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, username, avatar_url)
  VALUES (new.id, COALESCE(new.raw_user_meta_data->>'username', 'User ' || substr(new.id::text, 1, 4)), new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Create the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 3. Backfill existing users (JUST IN CASE)
INSERT INTO public.profiles (id, username)
SELECT id, email -- fallback to email if no username
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.profiles)
ON CONFLICT (id) DO NOTHING;
