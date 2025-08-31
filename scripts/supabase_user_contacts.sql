-- Supabase Setup: user_contacts Tabelle + RLS
-- 1) Erweiterungen sicherstellen
create extension if not exists pgcrypto;

-- 2) Tabelle
create table if not exists public.user_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  contacts jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  version int not null default 1,
  unique(user_id)
);

-- 3) Trigger für updated_at/version
create or replace function public.handle_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  new.version = coalesce(old.version, 1) + 1;
  return new;
end;
$$ language plpgsql;

drop trigger if exists on_user_contacts_updated on public.user_contacts;
create trigger on_user_contacts_updated
before update on public.user_contacts
for each row execute function public.handle_updated_at();

-- 4) RLS aktivieren
alter table public.user_contacts enable row level security;

-- 5) Policies
create policy if not exists "select_own_contacts" on public.user_contacts
for select to authenticated using (auth.uid() = user_id);

create policy if not exists "insert_own_contacts" on public.user_contacts
for insert to authenticated with check (auth.uid() = user_id);

create policy if not exists "update_own_contacts" on public.user_contacts
for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy if not exists "delete_own_contacts" on public.user_contacts
for delete to authenticated using (auth.uid() = user_id);

-- 6) Admin-Views (optional)
create or replace view public.admin_user_activity as
select u.id as user_id, u.email, u.created_at as user_created,
       uc.created_at as first_sync, uc.updated_at as last_sync,
       jsonb_array_length(coalesce(uc.contacts, '[]'::jsonb)) as contact_count,
       uc.version
from auth.users u
left join public.user_contacts uc on uc.user_id = u.id
order by uc.updated_at desc nulls last;