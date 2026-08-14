import React, { useState, useEffect } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import { Calendar, Tag, ArrowLeft, Edit, Trash2, RefreshCw } from 'lucide-react'
import { fetchEvent, deleteEvent } from '../services/api'
import Alert from '../components/Alert'

export default function EventDetails() {
  const { id } = useParams()
  const navigate = useNavigate()
  const [event, setEvent] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    const loadDetails = async () => {
      setLoading(true)
      try {
        const data = await fetchEvent(id)
        setEvent(data)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }
    loadDetails()
  }, [id])

  const handleDelete = async () => {
    if (!window.confirm('Are you sure you want to delete this event?')) return

    try {
      await deleteEvent(id)
      navigate('/', { state: { notice: 'Event deleted successfully' } })
    } catch (err) {
      setError(err.message)
    }
  }

  if (loading) {
    return (
      <div className="page-container loading-state">
        <RefreshCw className="spin-icon" size={32} />
        <p>Loading event details...</p>
      </div>
    )
  }

  if (error || !event) {
    return (
      <div className="page-container">
        <Link to="/" className="btn btn-outline btn-sm btn-icon mb-4">
          <ArrowLeft size={16} />
          <span>Back to Events</span>
        </Link>
        <Alert type="error" message={error || 'Event not found'} />
      </div>
    )
  }

  const formattedDate = new Date(event.start_at).toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })

  return (
    <div className="page-container">
      <Link to="/" className="btn btn-outline btn-sm btn-icon mb-4">
        <ArrowLeft size={16} />
        <span>Back to Events</span>
      </Link>

      <div className="event-detail-card">
        {event.image_url && (
          <div
            className="event-detail-banner"
            style={{ backgroundImage: `url(${event.image_url})` }}
          />
        )}

        <div className="event-detail-body">
          <div className="event-badge">
            <Tag size={14} />
            <span>{event.billetto_id}</span>
          </div>

          <h1 className="event-detail-title">{event.title}</h1>

          <div className="event-detail-meta">
            <Calendar size={18} />
            <span>{formattedDate}</span>
          </div>

          <div className="event-detail-section">
            <h3>Description</h3>
            <p className="event-detail-description">
              {event.description || 'No description provided for this event.'}
            </p>
          </div>

          <div className="event-detail-actions">
            <Link to={`/events/${event.id}/edit`} className="btn btn-primary btn-icon">
              <Edit size={18} />
              <span>Edit Event</span>
            </Link>
            <button onClick={handleDelete} className="btn btn-danger btn-icon">
              <Trash2 size={18} />
              <span>Delete Event</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  )
}
