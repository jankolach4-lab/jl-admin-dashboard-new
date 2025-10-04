'use client'

export default function Dashboard() {
  return (
    <div style={{ padding: '2rem', fontFamily: 'Arial, sans-serif' }}>
      <h1 style={{ color: '#2563eb', marginBottom: '2rem' }}>Admin Dashboard Pro</h1>
      
      <div style={{ 
        display: 'grid', 
        gridTemplateColumns: 'repeat(3, 1fr)', 
        gap: '2rem',
        marginBottom: '2rem'
      }}>
        <div style={{ 
          background: 'white', 
          padding: '1.5rem', 
          borderRadius: '0.75rem',
          boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
          textAlign: 'center'
        }}>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#2563eb' }}>3</div>
          <div style={{ fontSize: '0.875rem', color: '#6b7280' }}>PROJEKTE</div>
        </div>
        
        <div style={{ 
          background: 'white', 
          padding: '1.5rem', 
          borderRadius: '0.75rem',
          boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
          textAlign: 'center'
        }}>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#2563eb' }}>12</div>
          <div style={{ fontSize: '0.875rem', color: '#6b7280' }}>VP (VERTRIEBSPARTNER)</div>
        </div>
        
        <div style={{ 
          background: 'white', 
          padding: '1.5rem', 
          borderRadius: '0.75rem',
          boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
          textAlign: 'center'
        }}>
          <div style={{ fontSize: '2.5rem', fontWeight: 800, color: '#2563eb' }}>1,247</div>
          <div style={{ fontSize: '0.875rem', color: '#6b7280' }}>WE (WOHNEINHEITEN)</div>
        </div>
      </div>

      <div style={{
        background: 'white',
        padding: '1.5rem',
        borderRadius: '0.75rem',
        boxShadow: '0 4px 12px rgba(0,0,0,0.05)'
      }}>
        <h2 style={{ marginBottom: '1rem' }}>Projekte Übersicht</h2>
        <table style={{ width: '100%', borderCollapse: 'collapse' }}>
          <thead>
            <tr style={{ borderBottom: '2px solid #e5e7eb' }}>
              <th style={{ padding: '1rem', textAlign: 'left' }}>Projekt (Stadt)</th>
              <th style={{ padding: '1rem', textAlign: 'left' }}>WE</th>
              <th style={{ padding: '1rem', textAlign: 'left' }}>VP</th>
              <th style={{ padding: '1rem', textAlign: 'left' }}>Status %</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td style={{ padding: '1rem', fontWeight: 600 }}>Wiesbaden</td>
              <td style={{ padding: '1rem' }}>628</td>
              <td style={{ padding: '1rem' }}>4</td>
              <td style={{ padding: '1rem' }}>14%</td>
            </tr>
            <tr>
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
    </div>
  )
}
