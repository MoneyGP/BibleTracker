-- Forcefully DROP the constraint first (since we know it exists)
ALTER TABLE posts
DROP CONSTRAINT IF EXISTS posts_user_id_fkey;

-- Now Re-Create it ensuring it points to profiles(id)
ALTER TABLE posts
ADD CONSTRAINT posts_user_id_fkey
FOREIGN KEY (user_id)
REFERENCES profiles (id)
ON DELETE CASCADE;

-- Reload cache
NOTIFY pgrst, 'reload schema';
