import React, { useState, useEffect } from 'react'
import { useUser } from '@clerk/clerk-react'
import { User, Mail, Calendar, ShieldCheck } from 'lucide-react'
import { fetchEvents } from '../services/api'

export default function Profile() {
  const { user } = useUser()
  const [totalEvents, setTotalEvents] = useState(0)

  useEffect(() => {
    const loadStats = async () => {
      try {
        const data = await fetchEvents({ page: 1, per_page: 1 })
        setTotalEvents(data.pagination?.total || 0)
      } catch {
        // quiet error handle
      }
    }
    loadStats()
  }, [])

  if (!user) return null

  return (
    <div className="page-container form-page-container">
      <div className="card profile-card">
        <div className="profile-header">
          <img
            src={user.imageUrl}
            alt={user.fullName || 'User Avatar'}
            className="profile-avatar"
          />
          <div>
            <h1 className="profile-name">{user.fullName || 'Clerk User'}</h1>
            <p className="profile-badge">
              <ShieldCheck size={14} />
              <span>Clerk Authenticated</span>
            </p>
          </div>
        </div>

        <div className="profile-details-grid">
          <div className="profile-detail-item">
            <User size={18} className="detail-icon" />
            <div>
              <span className="detail-label">Clerk User ID</span>
              <span className="detail-value">{user.id}</span>
            </div>
          </div>

          <div className="profile-detail-item">
            <Mail size={18} className="detail-icon" />
            <div>
              <span className="detail-label">Primary Email</span>
              <span className="detail-value">
                {user.primaryEmailAddress?.emailAddress || 'No email attached'}
              </span>
            </div>
          </div>

          <div className="profile-detail-item">
            <Calendar size={18} className="detail-icon" />
            <div>
              <span className="detail-label">Total Events Owned</span>
              <span className="detail-value stat-highlight">{totalEvents}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
