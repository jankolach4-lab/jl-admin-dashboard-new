-- Fehlende User Summary und Hourly Changes Funktionen für Admin Dashboard
-- Diese Funktionen werden vom Admin Dashboard benötigt, aber waren nicht in den vorhandenen Scripts

set check_function_bodies = off;

-- 1) User hourly changes for a specific date
create or replace function public.fn_dashboard_user_hourly_changes(p_user_id uuid, p_date text)
returns table(hour integer, changes integer)
language sql security definer set search_path = public as $$
  select extract(hour from (coalesce(ase.occurred_at, ase.created_at) at time zone 'utc'))::int as hour,
         count(*)::int as changes
  from public.analytics_status_events ase
  where ase.user_id = p_user_id
    and (coalesce(ase.occurred_at, ase.created_at) at time zone 'utc')::date = p_date::date
  group by 1
  order by 1
$$;

-- 2) User summary metrics - FIXED JOIN LOGIC with contact_key
create or replace function public.fn_dashboard_user_summary_metrics(p_user_id uuid, p_project text)
returns jsonb language sql security definer set search_path = public as $$
  with user_changes as (
    -- All status changes for this user in this project
    select ase.resident_id, ase.status, ase.occurred_at, ase.created_at
    from public.analytics_status_events ase
    join public.analytics_residents ar on ar.resident_id = ase.resident_id
    left join public.analytics_contacts ac on ac.contact_key::text = ar.contact_id::text
    where ase.user_id = p_user_id
      and coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
  ), 
  completions as (
    -- Count completions (status = 'abschluss', not 'onlineabschluss')
    select count(*)::int as cnt
    from user_changes
    where status = 'abschluss'
  ),
  total_changes as (
    -- Total status changes
    select count(*)::int as cnt
    from user_changes
  ),
  we_with_status as (
    -- WE that have any status (distinct residents)
    select count(distinct resident_id)::int as cnt
    from user_changes
    where status is not null
  ),
  we_total as (
    -- Total WE for this user in this project
    select count(*)::int as cnt
    from public.analytics_residents ar
    left join public.analytics_contacts ac on ac.contact_key::text = ar.contact_id::text
    where ar.user_id = p_user_id
      and coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
  )
  select jsonb_build_object(
    'total_changes', (select cnt from total_changes),
    'completions', (select cnt from completions),
    'avg_changes_per_completion', case 
      when (select cnt from completions) > 0 
      then round((select cnt from total_changes)::numeric / (select cnt from completions)::numeric, 1)
      else 0 
    end,
    'we_with_status', (select cnt from we_with_status),
    'we_with_status_percent', case 
      when (select cnt from we_total) > 0 
      then round(((select cnt from we_with_status)::numeric / (select cnt from we_total)::numeric) * 100, 1)
      else 0 
    end,
    'we_total', (select cnt from we_total)
  )
$$;

-- 3) Guarded wrappers with admin check
create or replace function public.fn_dashboard_guarded_user_hourly_changes(p_user_id uuid, p_date text)
returns setof public.fn_dashboard_user_hourly_changes language plpgsql security definer set search_path = public as $$
begin 
  perform public.fn_require_admin(); 
  return query select * from public.fn_dashboard_user_hourly_changes(p_user_id, p_date); 
end; $$;

create or replace function public.fn_dashboard_guarded_user_summary_metrics(p_user_id uuid, p_project text)
returns jsonb language plpgsql security definer as $$
begin 
  perform public.fn_require_admin(); 
  return (select public.fn_dashboard_user_summary_metrics(p_user_id, p_project)); 
end; $$;

-- 4) Grants for authenticated users
grant execute on function public.fn_dashboard_guarded_user_hourly_changes(uuid, text) to authenticated;
grant execute on function public.fn_dashboard_guarded_user_summary_metrics(uuid, text) to authenticated;