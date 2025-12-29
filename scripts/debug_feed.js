
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
const path = require('path');

// Load .env.local manually
try {
    const envPath = path.resolve(__dirname, '../.env.local');
    const envConfig = fs.readFileSync(envPath, 'utf8');
    envConfig.split('\n').forEach(line => {
        const [key, value] = line.split('=');
        if (key && value) {
            process.env[key.trim()] = value.trim().replace(/^["']|["']$/g, '');
        }
    });
} catch (e) {
    console.error('Could not load .env.local', e);
}

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

console.log('Supabase URL:', supabaseUrl);
console.log('Supabase Key (first 10 chars):', supabaseAnonKey ? supabaseAnonKey.substring(0, 10) + '...' : 'MISSING');

const supabase = createClient(supabaseUrl, supabaseAnonKey);

async function debugFeed() {
    console.log('\n--- 1. Testing simple fetch (posts only) ---');
    const { data: simpleData, error: simpleError } = await supabase
        .from('posts')
        .select('*')
        .limit(1);

    if (simpleError) {
        console.error('FAILED (Simple):', simpleError);
    } else {
        console.log('SUCCESS (Simple). Rows:', simpleData.length);
    }

    console.log('\n--- 2. Testing simple fetch (profiles only) ---');
    const { data: profileData, error: profileError } = await supabase
        .from('profiles')
        .select('id, username')
        .limit(1);

    if (profileError) {
        console.error('FAILED (Profiles):', profileError);
    } else {
        console.log('SUCCESS (Profiles). Rows:', profileData.length);
    }

    console.log('\n--- 3. Testing Join (Standard) ---');
    const { data: joinData, error: joinError } = await supabase
        .from('posts')
        .select('*, profiles(username)')
        .limit(1);

    if (joinError) {
        console.error('FAILED (Join Standard):', joinError.message);
    } else {
        console.log('SUCCESS (Join Standard). Rows:', joinData.length);
    }

    console.log('\n--- 4. Testing Join (Explicit FK Hint) ---');
    const { data: hintData, error: hintError } = await supabase
        .from('posts')
        .select('*, profiles!posts_user_id_fkey(username)')
        .limit(1);

    if (hintError) {
        console.error('FAILED (Join Explicit):', hintError.message);
    } else {
        console.log('SUCCESS (Join Explicit). Rows:', hintData.length);
    }
}

debugFeed();
