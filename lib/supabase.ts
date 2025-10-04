import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: false
  }
})

// Types
export interface UserContact {
  user_id: string;
  contacts: ContactItem[];
  created_at: string;
  updated_at: string;
}

export interface ContactItem {
  ort: string;
  we: number;
  residents?: { [key: string]: { status?: string } };
}

export interface UserDirectory {
  user_id: string;
  email: string;
  display_name: string;
}

export interface ProjectData {
  name: string;
  totalWE: number;
  vps: Set<string>;
  completions: number;
  statusCounts: { [status: string]: number };
  dailyStats: { [date: string]: { completions: number; changes: number } };
}

export interface VPData {
  id: string;
  name: string;
  email: string;
  totalWE: number;
  completions: number;
  totalChanges: number;
  statusCounts: { [status: string]: number };
  dailyStats: { [date: string]: { completions: number; changes: number } };
  projects: Set<string>;
}