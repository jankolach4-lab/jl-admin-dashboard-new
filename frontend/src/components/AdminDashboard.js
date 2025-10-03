import React, { useState, useEffect, useRef } from 'react';

const AdminDashboard = () => {
  const [allProjects, setAllProjects] = useState([]);
  const [allUsers, setAllUsers] = useState([]);
  const [currentProject, setCurrentProject] = useState(null);
  const [currentUserId, setCurrentUserId] = useState(null);
  const [projectTotalWE, setProjectTotalWE] = useState(0);
  const [charts, setCharts] = useState({});
  const [supabase, setSupabase] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Initialize Supabase
  useEffect(() => {
    const initSupabase = async () => {
      try {
        // Load Supabase script
        if (!window.supabase) {
          const script = document.createElement('script');
          script.src = 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2';
          script.onload = () => {
            const SUPABASE_URL = 'https://whigasnqcvjkilkmbfld.supabase.co';
            const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndoaWdhc25xY3Zqa2lsa21iZmxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyNDE1OTIsImV4cCI6MjA2OTgxNzU5Mn0.tfUnIP_oWy3N9UM6Ws9mPiKqsGtj8_kIOMW42E298rc';
            
            const client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
              auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: false }
            });
            
            setSupabase(client);
          };
          document.head.appendChild(script);
        } else {
          const SUPABASE_URL = 'https://whigasnqcvjkilkmbfld.supabase.co';
          const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndoaWdhc25xY3Zqa2lsa21iZmxkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyNDE1OTIsImV4cCI6MjA2OTgxNzU5Mn0.tfUnIP_oWy3N9UM6Ws9mPiKqsGtj8_kIOMW42E298rc';
          
          const client = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
            auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: false }
          });
          
          setSupabase(client);
        }
      } catch (error) {
        setError('Fehler beim Initialisieren von Supabase: ' + error.message);
        setLoading(false);
      }
    };

    initSupabase();
  }, []);

  // Auth check
  useEffect(() => {
    if (!supabase) return;

    const checkAuth = async () => {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session) {
          window.location.href = '/admin-login';
          return;
        }
        setLoading(false);
        loadProjects();
      } catch (error) {
        setError('Authentifizierung fehlgeschlagen: ' + error.message);
        setLoading(false);
      }
    };

    checkAuth();
  }, [supabase]);

  // Load projects
  const loadProjects = async () => {
    if (!supabase) return;
    
    try {
      const { data, error } = await supabase.rpc('fn_dashboard_guarded_projects');
      if (error) {
        setError(error.message);
        return;
      }

      setAllProjects(data || []);
      setSuccess('Dashboard geladen!');
      
      // Setup debug functions
      window.debugDashboard = () => {
        console.log('=== Dashboard Debug Info ===');
        console.log('allProjects:', allProjects);
        console.log('allUsers:', allUsers);
        console.log('currentProject:', currentProject);
        console.log('currentUserId:', currentUserId);
        console.log('projectTotalWE:', projectTotalWE);
        
        return {
          projects: allProjects,
          users: allUsers,
          currentProject,
          currentUserId,
          projectTotalWE
        };
      };
      
      window.loadUserData = selectUser;
      console.log('✅ Debug functions available: debugDashboard(), loadUserData()');
      
    } catch (error) {
      setError('Fehler beim Laden der Projekte: ' + error.message);
    }
  };

  const selectUser = async (userId, name) => {
    setCurrentUserId(userId);
    // Implement user selection logic here
    console.log('User selected:', userId, name);
  };

  if (loading) {
    return (
      <div style={{ padding: '20px', textAlign: 'center' }}>
        <h2>Admin Dashboard wird geladen...</h2>
        <div>Bitte warten...</div>
      </div>
    );
  }

  return (
    <div style={{ minHeight: '100vh', backgroundColor: '#f5f7fa' }}>
      {/* Simple dashboard layout */}
      <header style={{ 
        padding: '14px 18px', 
        backgroundColor: 'white', 
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        borderBottom: '1px solid #e5e7eb'
      }}>
        <h1 style={{ margin: 0, color: '#2563eb' }}>Admin Dashboard Pro</h1>
      </header>

      <main style={{ padding: '20px' }}>
        {error && (
          <div style={{ 
            color: '#b91c1c', 
            backgroundColor: '#fee2e2', 
            border: '1px solid #fecaca', 
            padding: '12px 16px', 
            borderRadius: '8px',
            margin: '12px 0' 
          }}>
            Fehler: {error}
          </div>
        )}

        {success && (
          <div style={{ 
            color: '#166534', 
            backgroundColor: '#dcfce7', 
            border: '1px solid #bbf7d0', 
            padding: '12px 16px', 
            borderRadius: '8px',
            margin: '12px 0' 
          }}>
            {success}
          </div>
        )}

        <div style={{ display: 'grid', gridTemplateColumns: 'minmax(300px,380px) 1fr', gap: '16px' }}>
          {/* Sidebar */}
          <div style={{ 
            backgroundColor: 'white', 
            borderRadius: '12px', 
            padding: '16px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
          }}>
            <h3 style={{ marginBottom: '16px' }}>
              <i className="fas fa-building"></i> Projekte
            </h3>
            
            {/* KPI Cards */}
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit,minmax(80px,1fr))', gap: '12px', marginBottom: '16px' }}>
              <div style={{ background: 'white', padding: '12px', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
                <div style={{ fontSize: '20px', fontWeight: 'bold', color: '#2563eb' }}>
                  {allProjects.length}
                </div>
                <div style={{ fontSize: '10px', color: '#6b7280' }}>PROJEKTE</div>
              </div>
              <div style={{ background: 'white', padding: '12px', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
                <div style={{ fontSize: '20px', fontWeight: 'bold', color: '#2563eb' }}>
                  {allUsers.length}
                </div>
                <div style={{ fontSize: '10px', color: '#6b7280' }}>MITARBEITER</div>
              </div>
            </div>

            {/* Projects list */}
            <div style={{ maxHeight: '400px', overflowY: 'auto' }}>
              {allProjects.length > 0 ? (
                <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                  <thead>
                    <tr>
                      <th style={{ padding: '8px', textAlign: 'left', borderBottom: '1px solid #e5e7eb', fontSize: '12px' }}>
                        Projekt
                      </th>
                      <th style={{ padding: '8px', textAlign: 'left', borderBottom: '1px solid #e5e7eb', fontSize: '12px' }}>
                        WE
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {allProjects.map((project, index) => (
                      <tr 
                        key={index}
                        style={{ 
                          cursor: 'pointer',
                          backgroundColor: currentProject === project.project ? '#f3f4f6' : 'transparent'
                        }}
                        onClick={() => setCurrentProject(project.project)}
                        onMouseOver={(e) => e.target.parentElement.style.backgroundColor = '#f8fafc'}
                        onMouseOut={(e) => e.target.parentElement.style.backgroundColor = 
                          currentProject === project.project ? '#f3f4f6' : 'transparent'
                        }
                      >
                        <td style={{ padding: '8px', fontSize: '12px', borderBottom: '1px solid #f1f5f9' }}>
                          {project.project || '–'}
                        </td>
                        <td style={{ padding: '8px', fontSize: '12px', borderBottom: '1px solid #f1f5f9' }}>
                          <strong>{project.total_we || 0}</strong>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              ) : (
                <div style={{ textAlign: 'center', padding: '20px', color: '#6b7280' }}>
                  Keine Projekte gefunden
                </div>
              )}
            </div>
          </div>

          {/* Main content */}
          <div style={{ 
            backgroundColor: 'white', 
            borderRadius: '12px', 
            padding: '16px',
            boxShadow: '0 2px 8px rgba(0,0,0,0.1)'
          }}>
            <h3>Dashboard Inhalt</h3>
            {currentProject ? (
              <div>
                <p>Ausgewähltes Projekt: <strong>{currentProject}</strong></p>
                <p>Debug-Funktionen sind verfügbar in der Browser-Konsole:</p>
                <ul>
                  <li><code>debugDashboard()</code> - Debug-Informationen anzeigen</li>
                  <li><code>loadUserData(userId, name)</code> - Benutzer laden</li>
                </ul>
              </div>
            ) : (
              <p>Bitte wählen Sie ein Projekt aus der linken Liste aus.</p>
            )}
          </div>
        </div>
      </main>
    </div>
  );
};

export default AdminDashboard;