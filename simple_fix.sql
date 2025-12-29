-- Forcefully add the foreign key. 
-- If it errors with "already exists", that's fine, but based on your output it does NOT exist.

ALTER TABLE posts
ADD CONSTRAINT posts_user_id_fkey
FOREIGN KEY (user_id)
REFERENCES profiles (id)
ON DELETE CASCADE;

-- Force reload after adding
NOTIFY pgrst, 'reload schema';
