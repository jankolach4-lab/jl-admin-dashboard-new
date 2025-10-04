'use client'

import * as React from 'react'

interface DashboardHeaderProps {
  onRefresh: () => void;
  onDebug: () => void;
  onLogout: () => void;
}

export default function DashboardHeader({ onRefresh, onDebug, onLogout }: DashboardHeaderProps) {
  return (
    <header className="header">
      <div className="logo">
        📊 Admin Dashboard Pro
      </div>
      <div className="controls">
        <select className="select" id="timeRange" defaultValue="30" style={{
          padding: '0.5rem 0.75rem',
          border: '1px solid #d1d5db',
          borderRadius: '0.5rem',
          background: 'white',
          fontSize: '0.875rem'
        }}>
          <option value="7">7 Tage</option>
          <option value="14">14 Tage</option>
          <option value="30">30 Tage</option>
          <option value="90">90 Tage</option>
          <option value="120">120 Tage</option>
        </select>
        <button className="btn btn-primary" onClick={onRefresh}>
          🔄 Aktualisieren
        </button>
        <button className="btn btn-secondary" onClick={onDebug}>
          🐛 Debug
        </button>
        <button className="btn btn-secondary" onClick={onLogout}>
          🚪 Abmelden
        </button>
      </div>
    </header>
  )
}