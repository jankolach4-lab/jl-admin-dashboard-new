-- Performance-Optimierungen und erweiterte Analytics für Admin Dashboard
-- Diese Skripte erstellen Indizes und zusätzliche Funktionen für bessere Performance

set check_function_bodies = off;

-- 1) Performance-Indizes für bessere Query-Performance
-- Indizes für analytics_status_events
create index if not exists idx_analytics_status_events_user_id on public.analytics_status_events(user_id);
create index if not exists idx_analytics_status_events_occurred_at on public.analytics_status_events(occurred_at);
create index if not exists idx_analytics_status_events_created_at on public.analytics_status_events(created_at);
create index if not exists idx_analytics_status_events_status on public.analytics_status_events(status);
create index if not exists idx_analytics_status_events_user_occurred on public.analytics_status_events(user_id, occurred_at);
create index if not exists idx_analytics_status_events_status_occurred on public.analytics_status_events(status, occurred_at);

-- Indizes für analytics_residents
create index if not exists idx_analytics_residents_user_id on public.analytics_residents(user_id);
create index if not exists idx_analytics_residents_resident_key on public.analytics_residents(resident_key);
create index if not exists idx_analytics_residents_contact_id on public.analytics_residents(contact_id);

-- Indizes für analytics_contacts
create index if not exists idx_analytics_contacts_contact_key on public.analytics_contacts(contact_key);
create index if not exists idx_analytics_contacts_ort on public.analytics_contacts(ort);
create index if not exists idx_analytics_contacts_id on public.analytics_contacts(id);

-- 2) Erweiterte Analytics-Funktionen

-- Weekly activity heatmap
create or replace function public.fn_dashboard_weekly_activity(p_user_id uuid, p_days int default 30)
returns table(weekday integer, hour integer, changes integer)
language sql security definer set search_path = public as $$
  select extract(dow from (coalesce(ase.occurred_at, ase.created_at) at time zone 'utc'))::int as weekday,
         extract(hour from (coalesce(ase.occurred_at, ase.created_at) at time zone 'utc'))::int as hour,
         count(*)::int as changes
  from public.analytics_status_events ase
  where ($1 is null or ase.user_id = $1)
    and coalesce(ase.occurred_at, ase.created_at) >= (now() - ($2||' days')::interval)
  group by 1, 2
  order by 1, 2
$$;

-- Monthly trend analysis
create or replace function public.fn_dashboard_monthly_trend(p_project text default null, p_months int default 12)
returns table(month_year text, completions integer, changes integer, active_users integer)
language sql security definer set search_path = public as $$
  select to_char(date_trunc('month', coalesce(ase.occurred_at, ase.created_at)), 'YYYY-MM') as month_year,
         count(*) filter (where ase.status = 'abschluss')::int as completions,
         count(*)::int as changes,
         count(distinct ase.user_id)::int as active_users
  from public.analytics_status_events ase
  join public.analytics_residents ar on ar.resident_key = ase.resident_id
  left join public.analytics_contacts ac on (ac.id = ar.contact_id) or (ac.contact_id = ar.contact_id)
  where ($1 is null or coalesce(nullif(ac.ort,''), 'Unbekannt') = $1)
    and coalesce(ase.occurred_at, ase.created_at) >= (now() - ($2||' months')::interval)
  group by 1
  order by 1
$$;

-- Performance metrics
create or replace function public.fn_dashboard_performance_metrics()
returns jsonb language sql security definer set search_path = public as $$
  with stats as (
    select 
      count(*) as total_events,
      count(distinct user_id) as active_users,
      count(distinct resident_id) as unique_residents,
      count(*) filter (where status = 'abschluss') as total_completions,
      avg(case when status = 'abschluss' then 1 else 0 end) as completion_rate,
      min(coalesce(occurred_at, created_at)) as first_event,
      max(coalesce(occurred_at, created_at)) as last_event
    from public.analytics_status_events
    where coalesce(occurred_at, created_at) >= (now() - interval '30 days')
  )
  select jsonb_build_object(
    'total_events', total_events,
    'active_users', active_users,
    'unique_residents', unique_residents,
    'total_completions', total_completions,
    'completion_rate', round((completion_rate * 100)::numeric, 2),
    'avg_events_per_user', case when active_users > 0 then round(total_events::numeric / active_users, 1) else 0 end,
    'first_event', first_event,
    'last_event', last_event,
    'data_span_days', extract(days from (last_event - first_event))
  ) from stats
$$;

-- User leaderboard
create or replace function public.fn_dashboard_user_leaderboard(p_project text default null, p_days int default 30, p_limit int default 10)
returns table(user_id uuid, display_name text, email text, completions integer, changes integer, we_count integer, efficiency_score numeric)
language sql security definer set search_path = public as $$
  with user_stats as (
    select ase.user_id,
           count(*) filter (where ase.status = 'abschluss') as completions,
           count(*) as changes,
           count(distinct ase.resident_id) as we_count
    from public.analytics_status_events ase
    join public.analytics_residents ar on ar.resident_key = ase.resident_id
    left join public.analytics_contacts ac on (ac.id = ar.contact_id) or (ac.contact_id = ar.contact_id)
    where ($1 is null or coalesce(nullif(ac.ort,''), 'Unbekannt') = $1)
      and coalesce(ase.occurred_at, ase.created_at) >= (now() - ($2||' days')::interval)
    group by ase.user_id
  )
  select us.user_id,
         coalesce(ud.display_name, ud.email, us.user_id::text) as display_name,
         ud.email,
         us.completions,
         us.changes,
         us.we_count,
         case when us.changes > 0 then round((us.completions::numeric / us.changes * 100), 2) else 0 end as efficiency_score
  from user_stats us
  left join public.user_directory ud on ud.user_id = us.user_id
  order by efficiency_score desc, completions desc
  limit $3
$$;

-- Time-based activity patterns
create or replace function public.fn_dashboard_activity_patterns(p_user_id uuid default null, p_days int default 30)
returns jsonb language sql security definer set search_path = public as $$
  with hourly_pattern as (
    select extract(hour from (coalesce(ase.occurred_at, ase.created_at) at time zone 'utc'))::int as hour,
           count(*) as changes
    from public.analytics_status_events ase
    where ($1 is null or ase.user_id = $1)
      and coalesce(ase.occurred_at, ase.created_at) >= (now() - ($2||' days')::interval)
    group by 1
  ),
  daily_pattern as (
    select extract(dow from (coalesce(ase.occurred_at, ase.created_at) at time zone 'utc'))::int as weekday,
           count(*) as changes
    from public.analytics_status_events ase
    where ($1 is null or ase.user_id = $1)
      and coalesce(ase.occurred_at, ase.created_at) >= (now() - ($2||' days')::interval)
    group by 1
  ),
  peak_hours as (
    select hour, changes
    from hourly_pattern
    order by changes desc
    limit 3
  )
  select jsonb_build_object(
    'hourly_pattern', (select jsonb_object_agg(hour, changes) from hourly_pattern),
    'daily_pattern', (select jsonb_object_agg(weekday, changes) from daily_pattern),
    'peak_hours', (select jsonb_agg(jsonb_build_object('hour', hour, 'changes', changes)) from peak_hours),
    'most_active_hour', (select hour from hourly_pattern order by changes desc limit 1),
    'most_active_weekday', (select weekday from daily_pattern order by changes desc limit 1)
  )
$$;

-- 3) Guarded versions with admin check
create or replace function public.fn_dashboard_guarded_weekly_activity(p_user_id uuid, p_days int default 30)
returns setof public.fn_dashboard_weekly_activity language plpgsql security definer as $$
begin 
  perform public.fn_require_admin(); 
  return query select * from public.fn_dashboard_weekly_activity(p_user_id, p_days);
end; $$;

create or replace function public.fn_dashboard_guarded_monthly_trend(p_project text default null, p_months int default 12)
returns setof public.fn_dashboard_monthly_trend language plpgsql security definer as $$
begin 
  perform public.fn_require_admin(); 
  return query select * from public.fn_dashboard_monthly_trend(p_project, p_months);
end; $$;

create or replace function public.fn_dashboard_guarded_performance_metrics()
returns jsonb language plpgsql security definer as $$
begin 
  perform public.fn_require_admin(); 
  return (select public.fn_dashboard_performance_metrics());
end; $$;

create or replace function public.fn_dashboard_guarded_user_leaderboard(p_project text default null, p_days int default 30, p_limit int default 10)
returns setof public.fn_dashboard_user_leaderboard language plpgsql security definer as $$
begin 
  perform public.fn_require_admin(); 
  return query select * from public.fn_dashboard_user_leaderboard(p_project, p_days, p_limit);
end; $$;

create or replace function public.fn_dashboard_guarded_activity_patterns(p_user_id uuid default null, p_days int default 30)
returns jsonb language plpgsql security definer as $$
begin 
  perform public.fn_require_admin(); 
  return (select public.fn_dashboard_activity_patterns(p_user_id, p_days));
end; $$;

-- 4) Grants
grant execute on function public.fn_dashboard_guarded_weekly_activity(uuid, int) to authenticated;
grant execute on function public.fn_dashboard_guarded_monthly_trend(text, int) to authenticated;
grant execute on function public.fn_dashboard_guarded_performance_metrics() to authenticated;
grant execute on function public.fn_dashboard_guarded_user_leaderboard(text, int, int) to authenticated;
grant execute on function public.fn_dashboard_guarded_activity_patterns(uuid, int) to authenticated;

-- 5) Optional: Views for common queries (materialized for better performance)
create or replace view public.v_dashboard_daily_summary as
select date_trunc('day', coalesce(ase.occurred_at, ase.created_at))::date as day,
       count(*) as total_changes,
       count(*) filter (where ase.status = 'abschluss') as completions,
       count(distinct ase.user_id) as active_users,
       count(distinct ase.resident_id) as unique_residents
from public.analytics_status_events ase
where coalesce(ase.occurred_at, ase.created_at) >= (now() - interval '90 days')
group by 1
order by 1 desc;

-- Grant access to view
grant select on public.v_dashboard_daily_summary to authenticated;