'use client'

export default function Dashboard() {
  return (
    <div style={{ padding: '2rem' }}>
      <h1 style={{ color: '#2563eb', marginBottom: '2rem' }}>🚀 Admin Dashboard Pro</h1>
      
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', 
        gap: '2rem',
        marginBottom: '2rem'
      }}>
        <div style={{ 
          background: 'white', 
          padding: '1.5rem', 
          borderRadius: '12px',
          boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
          textAlign: 'center'
        }}>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#2563eb' }}>3</div>
          <div style={{ fontSize: '0.875rem', color: '#6b7280', fontWeight: 600 }}>PROJEKTE</div>
        </div>
        
        <div style={{ 
          background: 'white', 
          padding: '1.5rem', 
          borderRadius: '12px',
          boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
          textAlign: 'center'
        }}>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#2563eb' }}>12</div>
          <div style={{ fontSize: '0.875rem', color: '#6b7280', fontWeight: 600 }}>VP (VERTRIEBSPARTNER)</div>
        </div>
        
        <div style={{ 
          background: 'white', 
          padding: '1.5rem', 
          borderRadius: '12px',
          boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
          textAlign: 'center'
        }}>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#2563eb' }}>1,247</div>
          <div style={{ fontSize: '0.875rem', color: '#6b7280', fontWeight: 600 }}>WE (WOHNEINHEITEN)</div>
        </div>
      </div>

      <div style={{
        background: 'white',
        padding: '1.5rem',
        borderRadius: '12px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.1)'
      }}>
        <h2 style={{ marginBottom: '1rem', color: '#374151' }}>📊 Projekte Übersicht</h2>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ borderBottom: '2px solid #e5e7eb' }}>
              <th style={{ padding: '1rem', textAlign: 'left', color: '#6b7280' }}>Projekt (Stadt)</th>
              <th style={{ padding: '1rem', textAlign: 'left', color: '#6b7280' }}>WE</th>
              <th style={{ padding: '1rem', textAlign: 'left', color: '#6b7280' }}>VP</th>
              <th style={{ padding: '1rem', textAlign: 'left', color: '#6b7280' }}>Status %</th>
            </tr>
          </thead>
          <tbody>
            <tr style={{ borderBottom: '1px solid #f3f4f6' }}>
              <td style={{ padding: '1rem', fontWeight: 600 }}>Wiesbaden</td>
              <td style={{ padding: '1rem' }}>628</td>
              <td style={{ padding: '1rem' }}>4</td>
              <td style={{ padding: '1rem' }}>14%</td>
            </tr>
            <tr style={{ borderBottom: '1px solid #f3f4f6' }}>
              <td style={{ padding: '1rem', fontWeight: 600 }}>Alzey</td>
              <td style={{ padding: '1rem' }}>312</td>
              <td style={{ padding: '1rem' }}>3</td>
              <td style={{ padding: '1rem' }}>14%</td>
            </tr>
            <tr>
              <td style={{ padding: '1rem', fontWeight: 600 }}>Saal an der Donau</td>
              <td style={{ padding: '1rem' }}>307</td>
              <td style={{ padding: '1rem' }}>5</td>
              <td style={{ padding: '1rem' }}>24%</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div style={{
        marginTop: '2rem',
        padding: '1rem',
        background: '#10b981',
        color: 'white',
        borderRadius: '8px',
        textAlign: 'center'
      }}>
        ✅ Dashboard erfolgreich geladen! Supabase-Integration folgt als nächstes.
      </div>
    </div>
  )
}
