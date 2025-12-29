
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
    // We don't throw error here to allow build to pass without env vars, 
    // but functionalities will fail if these are missing.
    console.warn('Missing Supabase Environment Variables');
}

export const supabase = createClient(supabaseUrl || '', supabaseAnonKey || '');

if (typeof window !== 'undefined') {
    console.log('Supabase Client Initialized');
    console.log('URL:', supabaseUrl ? 'Present' : 'Missing');
    console.log('Key:', supabaseAnonKey ? 'Present' : 'Missing');
    if (!supabaseUrl || !supabaseAnonKey) {
        console.error('Supabase env vars are missing in the client! Check .env.local and ensure they start with NEXT_PUBLIC_');
    }
}
