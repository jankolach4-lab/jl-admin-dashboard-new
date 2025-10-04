'use client'

import * as React from 'react'
import { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { supabase } from '../../lib/supabase'

export default function LoginPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    // Check if user is already logged in
    const checkSession = async () => {
      const { data: { session } } = await supabase.auth.getSession()
      if (session) {
        router.push('/')
      }
    }
    checkSession()
  }, [router])

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (error) throw error

      if (data.user) {
        router.push('/')
      }
    } catch (error) {
      setError('Fehler beim Anmelden: ' + (error as Error).message)
    } finally {
      setLoading(false)
    }
  }

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
      })

      if (error) throw error

      if (data.user) {
        alert('Registrierung erfolgreich! Bitte überprüfen Sie Ihre E-Mail für die Bestätigung.')
        router.push('/')
      }
    } catch (error) {
      setError('Fehler bei der Registrierung: ' + (error as Error).message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div style={{
      minHeight: '100vh',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'var(--gray-50)'
    }}>
      <div style={{
        maxWidth: '420px',
        width: '100%',
        margin: '10vh auto',
        background: 'white',
        padding: '28px',
        borderRadius: '12px',
        boxShadow: '0 10px 30px rgba(0,0,0,.08)'
      }}>
        <h1 style={{
          fontSize: '22px',
          margin: '0 0 16px 0',
          textAlign: 'center',
          color: 'var(--gray-900)'
        }}>
          Admin Dashboard Login
        </h1>
        
        {error && (
          <div className="alert alert-error" style={{ marginBottom: '16px' }}>
            {error}
          </div>
        )}
        
        {loading && (
          <div style={{
            color: 'var(--primary)',
            textAlign: 'center',
            fontSize: '13px',
            marginBottom: '16px'
          }}>
            Bitte warten…
          </div>
        )}
        
        <form onSubmit={handleLogin} style={{
          display: 'flex',
          flexDirection: 'column',
          gap: '12px',
          marginTop: '8px'
        }}>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="E‑Mail"
            autoComplete="username"
            required
            style={{
              padding: '12px 14px',
              border: '1px solid var(--gray-300)',
              borderRadius: '10px',
              fontSize: '14px'
            }}
          />
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Passwort"
            autoComplete="current-password"
            required
            style={{
              padding: '12px 14px',
              border: '1px solid var(--gray-300)',
              borderRadius: '10px',
              fontSize: '14px'
            }}
          />
          <div style={{ display: 'flex', gap: '10px' }}>
            <button
              type="submit"
              disabled={loading}
              style={{
                background: 'var(--primary)',
                color: '#fff',
                border: 'none',
                padding: '12px 14px',
                borderRadius: '10px',
                cursor: 'pointer',
                fontWeight: 600,
                flex: 1,
                opacity: loading ? 0.6 : 1
              }}
            >
              Einloggen
            </button>
            <button
              type="button"
              onClick={handleSignup}
              disabled={loading}
              style={{
                background: '#111827',
                color: '#fff',
                border: 'none',
                padding: '12px 14px',
                borderRadius: '10px',
                cursor: 'pointer',
                fontWeight: 600,
                flex: 1,
                opacity: loading ? 0.6 : 1
              }}
            >
              Registrieren
            </button>
          </div>
          <p style={{
            color: 'var(--gray-500)',
            fontSize: '12px',
            textAlign: 'center',
            margin: 0
          }}>
            Admin‑Zugang erforderlich. Nach Login werden aggregierte Analytics geladen.
          </p>
        </form>
      </div>
    </div>
  )
}