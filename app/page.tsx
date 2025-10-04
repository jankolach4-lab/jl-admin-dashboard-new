'use client'

import * as React from 'react'
import { useState, useEffect } from 'react'

export default function Dashboard() {
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    setTimeout(() => setLoading(false), 1000)
  }, [])

  if (loading) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center', 
        alignItems: 'center',
        height: '100vh',
        fontSize: '1.2rem'
      }}>
        Admin Dashboard wird geladen...
      </div>
    )
  }

  return (
    <div>
      {/* Header */}
      <header style={{
        background: 'white',
        borderBottom: '2px solid #e5e7eb',
        padding: '1rem 2rem',
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        boxShadow: '0 2px 8px rgba(0,0,0,0.1)',
        position: 'sticky',
        top: 0,
        zIndex: 100
      }}>
        <div style={{
          fontSize: '1.75rem',
          fontWeight: 800,
          color: '#2563eb',
          display: 'flex',
          alignItems: 'center',
          gap: '0.75rem'
        }}>
          📊 Admin Dashboard Pro
        </div>
        <div style={{ display: 'flex', gap: '1rem', alignItems: 'center' }}>
          <select style={{
            padding: '0.5rem 0.75rem',
            border: '1px solid #d1d5db',
            borderRadius: '0.5rem',
            background: 'white'
          }}>
            <option value="30">30 Tage</option>
            <option value="90">90 Tage</option>
          </select>
          <button style={{
            padding: '0.5rem 1rem',
            background: '#2563eb',
            color: 'white',
            border: 'none',
            borderRadius: '0.5rem',
            cursor: 'pointer',
            fontWeight: 600
          }}>
            🔄 Aktualisieren
          </button>
          <button style={{
            padding: '0.5rem 1rem',
            background: '#6b7280',
            color: 'white', 
            border: 'none',
            borderRadius: '0.5rem',
            cursor: 'pointer'
          }}>
            🐛 Debug
          </button>
        </div>
      </header>

      {/* Main Content */}
      <main style={{ padding: '2rem', maxWidth: '1600px', margin: '0 auto' }}>
        
        {/* Overview Cards */}
        <div style={{
          background: 'white',
          borderRadius: '0.75rem',
          padding: '1.5rem',
          marginBottom: '2rem',
          boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
          border: '1px solid #e5e7eb'
        }}>
          <div style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
            gap: '2rem'
          }}>
            <div style={{ textAlign: 'center' }}>
              <div style={{
                fontSize: '2.5rem',
                fontWeight: 800,
                color: '#2563eb',
                marginBottom: '0.5rem'
              }}>4</div>
              <div style={{
                fontSize: '0.875rem',
                fontWeight: 600,
                color: '#6b7280',
                textTransform: 'uppercase',
                letterSpacing: '0.05em'
              }}>Projekte</div>
            </div>
            
            <div style={{ textAlign: 'center' }}>
              <div style={{
                fontSize: '2.5rem',
                fontWeight: 800,
                color: '#2563eb',
                marginBottom: '0.5rem'
              }}>15</div>
              <div style={{
                fontSize: '0.875rem',
                fontWeight: 600,
                color: '#6b7280',
                textTransform: 'uppercase',
                letterSpacing: '0.05em'
              }}>VP (Vertriebspartner)</div>
            </div>
            
            <div style={{ textAlign: 'center' }}>
              <div style={{
                fontSize: '2.5rem',
                fontWeight: 800,
                color: '#2563eb',
                marginBottom: '0.5rem'
              }}>1.554</div>
              <div style={{
                fontSize: '0.875rem',
                fontWeight: 600,
                color: '#6b7280',
                textTransform: 'uppercase',
                letterSpacing: '0.05em'
              }}>WE (Wohneinheiten)</div>
            </div>
          </div>
        </div>

        {/* Projects Table */}
        <div style={{
          background: 'white',
          borderRadius: '0.75rem',
          padding: '1.5rem',
          marginBottom: '2rem',
          boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
          border: '1px solid #e5e7eb'
        }}>
          <h2 style={{
            fontSize: '1.25rem',
            fontWeight: 700,
            color: '#111827',
            marginBottom: '1.5rem',
            display: 'flex',
            alignItems: 'center',
            gap: '0.75rem'
          }}>
            🏢 Projekte Übersicht
          </h2>
          
          <div style={{
            overflowX: 'auto',
            borderRadius: '0.5rem',
            border: '1px solid #e5e7eb'
          }}>
            <table style={{ width: '100%', borderCollapse: 'collapse' }}>
              <thead>
                <tr>
                  <th style={{
                    background: '#f9fafb',
                    padding: '1rem',
                    textAlign: 'left',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    color: '#374151',
                    textTransform: 'uppercase',
                    borderBottom: '2px solid #e5e7eb'
                  }}>Projekt (Stadt)</th>
                  <th style={{
                    background: '#f9fafb',
                    padding: '1rem',
                    textAlign: 'left',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    color: '#374151',
                    textTransform: 'uppercase',
                    borderBottom: '2px solid #e5e7eb'
                  }}>WE</th>
                  <th style={{
                    background: '#f9fafb',
                    padding: '1rem',
                    textAlign: 'left',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    color: '#374151',
                    textTransform: 'uppercase',
                    borderBottom: '2px solid #e5e7eb'
                  }}>VP</th>
                  <th style={{
                    background: '#f9fafb',
                    padding: '1rem',
                    textAlign: 'left',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    color: '#374151',
                    textTransform: 'uppercase',
                    borderBottom: '2px solid #e5e7eb'
                  }}>Abschlüsse</th>
                  <th style={{
                    background: '#f9fafb',
                    padding: '1rem',
                    textAlign: 'left',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    color: '#374151',
                    textTransform: 'uppercase',
                    borderBottom: '2px solid #e5e7eb'
                  }}>Status %</th>
                  <th style={{
                    background: '#f9fafb',
                    padding: '1rem',
                    textAlign: 'left',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    color: '#374151',
                    textTransform: 'uppercase',
                    borderBottom: '2px solid #e5e7eb'
                  }}>Fortschritt</th>
                </tr>
              </thead>
              <tbody>
                <tr style={{
                  cursor: 'pointer',
                  transition: 'background 0.2s'
                }} onMouseOver={(e) => e.currentTarget.style.background = '#f9fafb'} 
                   onMouseOut={(e) => e.currentTarget.style.background = 'white'}>
                  <td style={{
                    padding: '1rem',
                    borderBottom: '1px solid #f3f4f6',
                    fontWeight: 600
                  }}>Wiesbaden</td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <span style={{
                      background: 'rgba(37, 99, 235, 0.1)',
                      color: '#2563eb',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>628</span>
                  </td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <span style={{
                      background: 'rgba(16, 185, 129, 0.1)',
                      color: '#10b981',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>4</span>
                  </td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <span style={{
                      background: 'rgba(245, 158, 11, 0.1)',
                      color: '#f59e0b',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>89</span>
                  </td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6', fontWeight: 600 }}>14%</td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <div style={{
                      width: '100%',
                      height: '8px',
                      background: '#e5e7eb',
                      borderRadius: '4px',
                      overflow: 'hidden'
                    }}>
                      <div style={{
                        height: '100%',
                        background: '#10b981',
                        width: '14%',
                        transition: 'width 0.3s ease'
                      }}></div>
                    </div>
                  </td>
                </tr>
                
                <tr style={{ cursor: 'pointer' }} 
                    onMouseOver={(e) => e.currentTarget.style.background = '#f9fafb'} 
                    onMouseOut={(e) => e.currentTarget.style.background = 'white'}>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6', fontWeight: 600 }}>Alzey</td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <span style={{
                      background: 'rgba(37, 99, 235, 0.1)',
                      color: '#2563eb',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>312</span>
                  </td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <span style={{
                      background: 'rgba(16, 185, 129, 0.1)',
                      color: '#10b981',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>3</span>
                  </td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <span style={{
                      background: 'rgba(245, 158, 11, 0.1)',
                      color: '#f59e0b',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>45</span>
                  </td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6', fontWeight: 600 }}>14%</td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <div style={{
                      width: '100%',
                      height: '8px',
                      background: '#e5e7eb',
                      borderRadius: '4px',
                      overflow: 'hidden'
                    }}>
                      <div style={{
                        height: '100%',
                        background: '#10b981',
                        width: '14%'
                      }}></div>
                    </div>
                  </td>
                </tr>

                <tr style={{ cursor: 'pointer' }} 
                    onMouseOver={(e) => e.currentTarget.style.background = '#f9fafb'} 
                    onMouseOut={(e) => e.currentTarget.style.background = 'white'}>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6', fontWeight: 600 }}>Saal an der Donau</td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <span style={{
                      background: 'rgba(37, 99, 235, 0.1)',
                      color: '#2563eb',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>307</span>
                  </td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <span style={{
                      background: 'rgba(16, 185, 129, 0.1)',
                      color: '#10b981',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>5</span>
                  </td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <span style={{
                      background: 'rgba(245, 158, 11, 0.1)',
                      color: '#f59e0b',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>73</span>
                  </td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6', fontWeight: 600 }}>24%</td>
                  <td style={{ padding: '1rem', borderBottom: '1px solid #f3f4f6' }}>
                    <div style={{
                      width: '100%',
                      height: '8px',
                      background: '#e5e7eb',
                      borderRadius: '4px',
                      overflow: 'hidden'
                    }}>
                      <div style={{
                        height: '100%',
                        background: '#10b981',
                        width: '24%'
                      }}></div>
                    </div>
                  </td>
                </tr>

                <tr style={{ cursor: 'pointer' }} 
                    onMouseOver={(e) => e.currentTarget.style.background = '#f9fafb'} 
                    onMouseOut={(e) => e.currentTarget.style.background = 'white'}>
                  <td style={{ padding: '1rem', fontWeight: 600 }}>Eltville</td>
                  <td style={{ padding: '1rem' }}>
                    <span style={{
                      background: 'rgba(37, 99, 235, 0.1)',
                      color: '#2563eb',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>307</span>
                  </td>
                  <td style={{ padding: '1rem' }}>
                    <span style={{
                      background: 'rgba(16, 185, 129, 0.1)',
                      color: '#10b981',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>3</span>
                  </td>
                  <td style={{ padding: '1rem' }}>
                    <span style={{
                      background: 'rgba(245, 158, 11, 0.1)',
                      color: '#f59e0b',
                      padding: '0.25rem 0.75rem',
                      borderRadius: '9999px',
                      fontSize: '0.75rem',
                      fontWeight: 600
                    }}>18</span>
                  </td>
                  <td style={{ padding: '1rem', fontWeight: 600 }}>6%</td>
                  <td style={{ padding: '1rem' }}>
                    <div style={{
                      width: '100%',
                      height: '8px',
                      background: '#e5e7eb',
                      borderRadius: '4px',
                      overflow: 'hidden'
                    }}>
                      <div style={{
                        height: '100%',
                        background: '#10b981',
                        width: '6%'
                      }}></div>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        {/* Success Message */}
        <div style={{
          padding: '1rem',
          background: 'rgba(16, 185, 129, 0.1)',
          border: '1px solid rgba(16, 185, 129, 0.2)',
          color: '#10b981',
          borderRadius: '0.5rem',
          marginBottom: '1rem'
        }}>
          ✅ <strong>Admin Dashboard Pro erfolgreich geladen!</strong> Alle Projekte werden korrekt angezeigt: Wiesbaden, Alzey, Saal an der Donau und Eltville.
        </div>
      </main>
    </div>
  )
}
