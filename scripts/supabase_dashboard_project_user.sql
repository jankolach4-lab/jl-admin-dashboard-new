-- SQL for additional project/user metrics & guarded RPCs
-- 1) Project daily completions (status = 'abschluss', exclude 'onlineabschluss')
create or replace function public.fn_dashboard_project_daily_completions(p_project text, p_days int)
returns table(day date, completions integer)
language sql security definer set search_path = public as $$
  select (coalesce(ase.occurred_at, ase.created_at) at time zone 'utc')::date as day,
         count(*)::int as completions
  from public.analytics_status_events ase
  join public.analytics_residents ar on ar.resident_id = ase.resident_id
  left join public.analytics_contacts ac on (ac.id = ar.contact_id) or (ac.contact_id = ar.contact_id)
  where coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
    and ase.status = 'abschluss'
    and coalesce(ase.occurred_at, ase.created_at) >= (now() - (p_days||' days')::interval)
  group by 1
  order by 1
$$;

-- 2) Project daily status changes (all events)
create or replace function public.fn_dashboard_project_daily_changes(p_project text, p_days int)
returns table(day date, changes integer)
language sql security definer set search_path = public as $$
  select (coalesce(ase.occurred_at, ase.created_at) at time zone 'utc')::date as day,
         count(*)::int as changes
  from public.analytics_status_events ase
  join public.analytics_residents ar on ar.resident_id = ase.resident_id
  left join public.analytics_contacts ac on (ac.id = ar.contact_id) or (ac.contact_id = ar.contact_id)
  where coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
    and coalesce(ase.occurred_at, ase.created_at) >= (now() - (p_days||' days')::interval)
  group by 1
  order by 1
$$;

-- 3) Project status breakdown + table (percent vs project WE total from contacts)
create or replace function public.fn_dashboard_project_status_table(p_project text)
returns jsonb language sql security definer set search_path = public as $$
  with last_status as (
    select distinct on (ase.resident_id)
           ase.resident_id,
           ase.status
    from public.analytics_status_events ase
    join public.analytics_residents ar on ar.resident_id = ase.resident_id
    left join public.analytics_contacts ac on (ac.id = ar.contact_id) or (ac.contact_id = ar.contact_id)
    where coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
    order by ase.resident_id, coalesce(ase.occurred_at, ase.created_at) desc
  ), agg as (
    select status, count(*)::int as cnt
    from last_status
    where status is not null
    group by status
  ), total as (
    select count(*)::numeric as total_we
    from public.analytics_contacts ac
    where coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
  ), tbl as (
    select a.status, a.cnt as absolute, case when t.total_we > 0 then round((a.cnt/t.total_we)*100,1) else 0 end as percent
    from agg a cross join total t
  )
  select jsonb_build_object(
    'breakdown', coalesce((select jsonb_object_agg(status, absolute) from tbl), '{}'::jsonb),
    'table', coalesce((select jsonb_agg(jsonb_build_object('status', status, 'absolute', absolute, 'percent', percent)) from tbl), '[]'::jsonb)
  )
$$;

-- 4) User daily completions
create or replace function public.fn_dashboard_user_daily_completions(p_user_id uuid, p_days int)
returns table(day date, completions integer)
language sql security definer set search_path = public as $$
  select (coalesce(ase.occurred_at, ase.created_at) at time zone 'utc')::date as day,
         count(*)::int as completions
  from public.analytics_status_events ase
  where ase.user_id = p_user_id
    and ase.status = 'abschluss'
    and coalesce(ase.occurred_at, ase.created_at) >= (now() - (p_days||' days')::interval)
  group by 1
  order by 1
$$;

-- 5) User status table (percent vs project total WE)
create or replace function public.fn_dashboard_user_status_table(p_user_id uuid, p_project text)
returns jsonb language sql security definer set search_path = public as $$
  with last_status as (
    select distinct on (ase.resident_id)
           ase.resident_id,
           ase.status
    from public.analytics_status_events ase
    join public.analytics_residents ar on ar.resident_id = ase.resident_id
    left join public.analytics_contacts ac on (ac.id = ar.contact_id) or (ac.contact_id = ar.contact_id)
    where ase.user_id = p_user_id
      and coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
    order by ase.resident_id, coalesce(ase.occurred_at, ase.created_at) desc
  ), agg as (
    select status, count(*)::int as cnt
    from last_status
    where status is not null
    group by status
  ), total as (
    select count(*)::numeric as total_we
    from public.analytics_contacts ac
    where coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
  ), tbl as (
    select a.status, a.cnt as absolute, case when t.total_we > 0 then round((a.cnt/t.total_we)*100,1) else 0 end as percent
    from agg a cross join total t
  )
  select jsonb_build_object(
    'breakdown', coalesce((select jsonb_object_agg(status, absolute) from tbl), '{}'::jsonb),
    'table', coalesce((select jsonb_agg(jsonb_build_object('status', status, 'absolute', absolute, 'percent', percent)) from tbl), '[]'::jsonb)
  )
$$;

-- 6) Guarded wrappers & grants
create or replace function public.fn_dashboard_guarded_project_daily_completions(p_project text, p_days int)
returns setof public.fn_dashboard_project_daily_completions language plpgsql security definer set search_path = public as $$
begin perform public.fn_require_admin(); return query select * from public.fn_dashboard_project_daily_completions(p_project, p_days); end; $$;

create or replace function public.fn_dashboard_guarded_project_daily_changes(p_project text, p_days int)
returns setof public.fn_dashboard_project_daily_changes language plpgsql security definer set search_path = public as $$
begin perform public.fn_require_admin(); return query select * from public.fn_dashboard_project_daily_changes(p_project, p_days); end; $$;

create or replace function public.fn_dashboard_guarded_project_status_table(p_project text)
returns jsonb language plpgsql security definer set search_path = public as $$
begin perform public.fn_require_admin(); return (select public.fn_dashboard_project_status_table(p_project)); end; $$;

create or replace function public.fn_dashboard_guarded_user_daily_completions(p_user_id uuid, p_days int)
returns setof public.fn_dashboard_user_daily_completions language plpgsql security definer set search_path = public as $$
begin perform public.fn_require_admin(); return query select * from public.fn_dashboard_user_daily_completions(p_user_id, p_days); end; $$;

create or replace function public.fn_dashboard_guarded_user_status_table(p_user_id uuid, p_project text)
returns jsonb language plpgsql security definer set search_path = public as $$
begin perform public.fn_require_admin(); return (select public.fn_dashboard_user_status_table(p_user_id, p_project)); end; $$;

grant execute on function public.fn_dashboard_guarded_project_daily_completions(text,int) to authenticated;
grant execute on function public.fn_dashboard_guarded_project_daily_changes(text,int) to authenticated;
grant execute on function public.fn_dashboard_guarded_project_status_table(text) to authenticated;
grant execute on function public.fn_dashboard_guarded_user_daily_completions(uuid,int) to authenticated;
grant execute on function public.fn_dashboard_guarded_user_status_table(uuid,text) to authenticated;