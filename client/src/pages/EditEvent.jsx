import React, { useState, useEffect } from 'react'
import { useParams, Link, useNavigate } from 'react-router-dom'
import { ArrowLeft, RefreshCw } from 'lucide-react'
import { fetchEvent, updateEvent } from '../services/api'
import EventForm from '../components/EventForm'
import Alert from '../components/Alert'

export default function EditEvent() {
  const { id } = useParams()
  const navigate = useNavigate()
  const [event, setEvent] = useState(null)
  const [loading, setLoading] = useState(true)
  const [isSubmitting, setIsSubmitting] = useState(false)
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

  const handleSubmit = async (formData) => {
    setIsSubmitting(true)
    setError(null)
    try {
      await updateEvent(id, formData)
      navigate(`/events/${id}`, { state: { notice: 'Event updated successfully' } })
    } catch (err) {
      setError(err.message)
    } finally {
      setIsSubmitting(false)
    }
  }

  if (loading) {
    return (
      <div className="page-container loading-state">
        <RefreshCw className="spin-icon" size={32} />
        <p>Loading event data...</p>
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

  return (
    <div className="page-container form-page-container">
      <Link to={`/events/${id}`} className="btn btn-outline btn-sm btn-icon mb-4">
        <ArrowLeft size={16} />
        <span>Back to Details</span>
      </Link>

      <div className="card">
        <h1 className="page-title">Edit Event</h1>
        <p className="page-subtitle mb-6">Update the event details below.</p>

        <Alert type="error" message={error} onClose={() => setError(null)} />

        <EventForm initialData={event} onSubmit={handleSubmit} isSubmitting={isSubmitting} />
      </div>
    </div>
  )
}
