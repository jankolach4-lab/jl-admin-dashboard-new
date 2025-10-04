'use client'

import React from 'react'

interface OverviewSectionProps {
  totalProjects: number;
  totalVPs: number;
  totalWE: number;
}

export default function OverviewSection({ totalProjects, totalVPs, totalWE }: OverviewSectionProps) {
  return (
    <div className="overview-row">
      <div className="overview-grid">
        <div className="overview-item">
          <div className="overview-value">{totalProjects}</div>
          <div className="overview-label">Projekte</div>
        </div>
        <div className="overview-item">
          <div className="overview-value">{totalVPs}</div>
          <div className="overview-label">VP (Vertriebspartner)</div>
        </div>
        <div className="overview-item">
          <div className="overview-value">{totalWE.toLocaleString()}</div>
          <div className="overview-label">WE (Wohneinheiten)</div>
        </div>
      </div>
    </div>
  )
}