-- Safely add the Foreign Key if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'posts_user_id_fkey') THEN
        ALTER TABLE posts
        ADD CONSTRAINT posts_user_id_fkey
        FOREIGN KEY (user_id)
        REFERENCES profiles (id)
        ON DELETE CASCADE;
    END IF;
END $$;

-- Force Supabase to refresh its schema cache
-- This makes the API (PostgREST) see the new relationship immediately.
NOTIFY pgrst, 'reload schema';
