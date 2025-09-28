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

-- 7) RPC-Funktion für sichere Upsert-Operation mit expliziter user_id
create or replace function public.fn_public_upsert_user_contacts(
  p_user_id uuid,
  p_contacts jsonb
)
returns void
security definer
language plpgsql
as $$
begin
  -- Nur wenn authentifiziert und user_id stimmt überein
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  
  if auth.uid() != p_user_id then
    raise exception 'Access denied: user_id mismatch';
  end if;

  -- Upsert mit UPDATE-dann-INSERT Pattern für Robustheit
  update public.user_contacts 
  set 
    contacts = p_contacts,
    updated_at = now(),
    version = version + 1
  where user_id = p_user_id;
  
  if not found then
    insert into public.user_contacts (user_id, contacts)
    values (p_user_id, p_contacts);
  end if;
end;
$$;

-- 8) Wrapper für alte Clients ohne p_user_id Parameter
create or replace function public.fn_public_upsert_user_contacts(
  p_contacts jsonb
)
returns void
security definer
language plpgsql
as $$
begin
  -- user_id aus auth.uid() ableiten
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;
  
  perform public.fn_public_upsert_user_contacts(auth.uid(), p_contacts);
end;
$$;

-- 9) Analytics Tabellen für Event-Tracking und Dashboard
create table if not exists public.analytics_contacts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  contact_key text not null,
  plz text,
  ort text,
  strasse text,
  nummer text,
  zusatz text,
  we integer,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, contact_key)
);

create table if not exists public.analytics_residents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  contact_id text not null, -- entspricht contact_key
  resident_name text,
  unit_number integer,
  status text,
  phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.analytics_status_events (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  contact_key text,
  resident_name text,
  unit_number integer,
  status text,
  timestamp timestamptz,
  created_at timestamptz not null default now()
);

-- RLS für Analytics-Tabellen
alter table public.analytics_contacts enable row level security;
alter table public.analytics_residents enable row level security;
alter table public.analytics_status_events enable row level security;

-- Policies für Analytics-Tabellen
create policy if not exists "analytics_contacts_policy" on public.analytics_contacts
for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy if not exists "analytics_residents_policy" on public.analytics_residents
for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy if not exists "analytics_status_events_policy" on public.analytics_status_events
for all to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Indexes für Performance
create index if not exists idx_analytics_contacts_user_contact on public.analytics_contacts(user_id, contact_key);
create index if not exists idx_analytics_residents_contact on public.analytics_residents(contact_id);
create index if not exists idx_analytics_status_events_user_contact on public.analytics_status_events(user_id, contact_key) where contact_key is not null;

-- 10) Event-Logging-Funktion
create or replace function public.fn_log_events_from_contacts_snapshot(
  p_user_id uuid,
  p_contacts jsonb
)
returns void
security definer
language plpgsql
as $$
declare
  contact_item jsonb;
  resident_item jsonb;
  status_entry jsonb;
  contact_key_val text;
begin
  -- Authentifizierung prüfen
  if auth.uid() is null or auth.uid() != p_user_id then
    raise exception 'Access denied';
  end if;

  -- Über alle Kontakte iterieren
  for contact_item in select jsonb_array_elements(p_contacts)
  loop
    -- Contact-Key generieren (MD5 aus Adresse)
    contact_key_val := md5(
      coalesce(contact_item->>'plz', '') || '|' ||
      coalesce(contact_item->>'ort', '') || '|' ||
      coalesce(contact_item->>'strasse', '') || '|' ||
      coalesce(contact_item->>'nummer', '') || '|' ||
      coalesce(contact_item->>'zusatz', '')
    );

    -- Analytics Contact upserten
    insert into public.analytics_contacts (
      user_id, contact_key, plz, ort, strasse, nummer, zusatz, we
    )
    values (
      p_user_id, 
      contact_key_val,
      contact_item->>'plz',
      contact_item->>'ort', 
      contact_item->>'strasse',
      contact_item->>'nummer',
      contact_item->>'zusatz',
      (contact_item->>'we')::integer
    )
    on conflict (user_id, contact_key) do update set
      plz = excluded.plz,
      ort = excluded.ort,
      strasse = excluded.strasse,
      nummer = excluded.nummer,
      zusatz = excluded.zusatz,
      we = excluded.we,
      updated_at = now();

    -- Residents verarbeiten
    if contact_item ? 'residents' then
      for resident_item in select jsonb_array_elements(contact_item->'residents')
      loop
        -- Status History Events loggen
        if resident_item ? 'statusHistory' then
          for status_entry in select jsonb_array_elements(resident_item->'statusHistory')
          loop
            insert into public.analytics_status_events (
              user_id, contact_key, resident_name, unit_number, status, timestamp
            )
            values (
              p_user_id,
              contact_key_val,
              resident_item->>'name',
              (resident_item->>'unit')::integer,
              status_entry->>'status',
              to_timestamp((status_entry->>'timestamp')::bigint / 1000)
            )
            on conflict do nothing; -- Events nicht doppelt loggen
          end loop;
        end if;
      end loop;
    end if;
  end loop;
end;
$$;