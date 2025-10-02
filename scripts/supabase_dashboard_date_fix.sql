-- Fix für "Invalid Date" Problem im Admin Dashboard
-- Alle täglich aggregierten Funktionen sollen das Datum als 'YYYY-MM-DD' String zurückgeben

-- 1) Project daily completions - Datum als String formatieren
DROP FUNCTION IF EXISTS public.fn_dashboard_project_daily_completions(text, int) CASCADE;
CREATE OR REPLACE FUNCTION public.fn_dashboard_project_daily_completions(p_project text, p_days int)
RETURNS TABLE(day text, completions integer)
LANGUAGE SQL SECURITY DEFINER SET search_path = public AS $$
  SELECT to_char((coalesce(ase.occurred_at, ase.created_at) at time zone 'utc')::date, 'YYYY-MM-DD') as day,
         count(*)::int as completions
  FROM public.analytics_status_events ase
  JOIN public.analytics_residents ar ON ar.resident_id = ase.resident_id
  LEFT JOIN public.analytics_contacts ac ON (ac.id = ar.contact_id) OR (ac.contact_id = ar.contact_id)
  WHERE coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
    AND ase.status = 'abschluss'
    AND coalesce(ase.occurred_at, ase.created_at) >= (now() - (p_days||' days')::interval)
  GROUP BY 1
  ORDER BY 1
$$;

-- 2) Project daily changes - Datum als String formatieren
DROP FUNCTION IF EXISTS public.fn_dashboard_project_daily_changes(text, int) CASCADE;
CREATE OR REPLACE FUNCTION public.fn_dashboard_project_daily_changes(p_project text, p_days int)
RETURNS TABLE(day text, changes integer)
LANGUAGE SQL SECURITY DEFINER SET search_path = public AS $$
  SELECT to_char((coalesce(ase.occurred_at, ase.created_at) at time zone 'utc')::date, 'YYYY-MM-DD') as day,
         count(*)::int as changes
  FROM public.analytics_status_events ase
  JOIN public.analytics_residents ar ON ar.resident_id = ase.resident_id
  LEFT JOIN public.analytics_contacts ac ON (ac.id = ar.contact_id) OR (ac.contact_id = ar.contact_id)
  WHERE coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
    AND coalesce(ase.occurred_at, ase.created_at) >= (now() - (p_days||' days')::interval)
  GROUP BY 1
  ORDER BY 1
$$;

-- 3) User daily completions (GLOBAL) - Datum als String formatieren
DROP FUNCTION IF EXISTS public.fn_dashboard_user_daily_completions(uuid, int) CASCADE;
CREATE OR REPLACE FUNCTION public.fn_dashboard_user_daily_completions(p_user_id uuid, p_days int)
RETURNS TABLE(day text, completions integer)
LANGUAGE SQL SECURITY DEFINER SET search_path = public AS $$
  SELECT to_char((coalesce(ase.occurred_at, ase.created_at) at time zone 'utc')::date, 'YYYY-MM-DD') as day,
         count(*)::int as completions
  FROM public.analytics_status_events ase
  WHERE ase.user_id = p_user_id
    AND ase.status = 'abschluss'
    AND coalesce(ase.occurred_at, ase.created_at) >= (now() - (p_days||' days')::interval)
  GROUP BY 1
  ORDER BY 1
$$;

-- 4) User daily completions (PROJECT-SCOPED) - Datum als String formatieren
DROP FUNCTION IF EXISTS public.fn_dashboard_user_daily_completions_project(uuid, text, int) CASCADE;
CREATE OR REPLACE FUNCTION public.fn_dashboard_user_daily_completions_project(p_user_id uuid, p_project text, p_days int)
RETURNS TABLE(day text, completions integer)
LANGUAGE SQL SECURITY DEFINER SET search_path = public AS $$
  SELECT to_char((coalesce(ase.occurred_at, ase.created_at) at time zone 'utc')::date, 'YYYY-MM-DD') as day,
         count(*)::int as completions
  FROM public.analytics_status_events ase
  JOIN public.analytics_residents ar ON ar.resident_id = ase.resident_id
  LEFT JOIN public.analytics_contacts ac ON (ac.id = ar.contact_id) OR (ac.contact_id = ar.contact_id)
  WHERE ase.user_id = p_user_id
    AND coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
    AND ase.status = 'abschluss'
    AND coalesce(ase.occurred_at, ase.created_at) >= (now() - (p_days||' days')::interval)
  GROUP BY 1
  ORDER BY 1
$$;

-- 5) User daily changes (PROJECT-SCOPED) - Datum als String formatieren
DROP FUNCTION IF EXISTS public.fn_dashboard_user_daily_changes_project(uuid, text, int) CASCADE;
CREATE OR REPLACE FUNCTION public.fn_dashboard_user_daily_changes_project(p_user_id uuid, p_project text, p_days int)
RETURNS TABLE(day text, changes integer)
LANGUAGE SQL SECURITY DEFINER SET search_path = public AS $$
  SELECT to_char((coalesce(ase.occurred_at, ase.created_at) at time zone 'utc')::date, 'YYYY-MM-DD') as day,
         count(*)::int as changes
  FROM public.analytics_status_events ase
  JOIN public.analytics_residents ar ON ar.resident_id = ase.resident_id
  LEFT JOIN public.analytics_contacts ac ON (ac.id = ar.contact_id) OR (ac.contact_id = ar.contact_id)
  WHERE ase.user_id = p_user_id
    AND coalesce(nullif(ac.ort,''), 'Unbekannt') = p_project
    AND coalesce(ase.occurred_at, ase.created_at) >= (now() - (p_days||' days')::interval)
  GROUP BY 1
  ORDER BY 1
$$;

-- Guarded Wrappers neu erstellen
CREATE OR REPLACE FUNCTION public.fn_dashboard_guarded_project_daily_completions(p_project text, p_days int)
RETURNS SETOF public.fn_dashboard_project_daily_completions LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN 
  PERFORM public.fn_require_admin(); 
  RETURN QUERY SELECT * FROM public.fn_dashboard_project_daily_completions(p_project, p_days); 
END; $$;

CREATE OR REPLACE FUNCTION public.fn_dashboard_guarded_project_daily_changes(p_project text, p_days int)
RETURNS SETOF public.fn_dashboard_project_daily_changes LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN 
  PERFORM public.fn_require_admin(); 
  RETURN QUERY SELECT * FROM public.fn_dashboard_project_daily_changes(p_project, p_days); 
END; $$;

CREATE OR REPLACE FUNCTION public.fn_dashboard_guarded_user_daily_completions(p_user_id uuid, p_days int)
RETURNS SETOF public.fn_dashboard_user_daily_completions LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN 
  PERFORM public.fn_require_admin(); 
  RETURN QUERY SELECT * FROM public.fn_dashboard_user_daily_completions(p_user_id, p_days); 
END; $$;

CREATE OR REPLACE FUNCTION public.fn_dashboard_guarded_user_daily_completions_project(p_user_id uuid, p_project text, p_days int)
RETURNS SETOF public.fn_dashboard_user_daily_completions_project LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN 
  PERFORM public.fn_require_admin(); 
  RETURN QUERY SELECT * FROM public.fn_dashboard_user_daily_completions_project(p_user_id, p_project, p_days); 
END; $$;

CREATE OR REPLACE FUNCTION public.fn_dashboard_guarded_user_daily_changes_project(p_user_id uuid, p_project text, p_days int)
RETURNS SETOF public.fn_dashboard_user_daily_changes_project LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN 
  PERFORM public.fn_require_admin(); 
  RETURN QUERY SELECT * FROM public.fn_dashboard_user_daily_changes_project(p_user_id, p_project, p_days); 
END; $$;

-- Grants
GRANT EXECUTE ON FUNCTION public.fn_dashboard_guarded_project_daily_completions(text,int) TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_dashboard_guarded_project_daily_changes(text,int) TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_dashboard_guarded_user_daily_completions(uuid,int) TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_dashboard_guarded_user_daily_completions_project(uuid,text,int) TO authenticated;
GRANT EXECUTE ON FUNCTION public.fn_dashboard_guarded_user_daily_changes_project(uuid,text,int) TO authenticated;