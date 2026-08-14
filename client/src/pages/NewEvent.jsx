import React, { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { ArrowLeft } from 'lucide-react'
import { createEvent } from '../services/api'
import EventForm from '../components/EventForm'
import Alert from '../components/Alert'

export default function NewEvent() {
  const navigate = useNavigate()
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [error, setError] = useState(null)

  const handleSubmit = async (formData) => {
    setIsSubmitting(true)
    setError(null)
    try {
      await createEvent(formData)
      navigate('/', { state: { notice: 'Event created successfully' } })
    } catch (err) {
      setError(err.message)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="page-container form-page-container">
      <Link to="/" className="btn btn-outline btn-sm btn-icon mb-4">
        <ArrowLeft size={16} />
        <span>Back to Events</span>
      </Link>

      <div className="card">
        <h1 className="page-title">Create New Event</h1>
        <p className="page-subtitle mb-6">Enter the event parameters to publish to your events dashboard.</p>

        <Alert type="error" message={error} onClose={() => setError(null)} />

        <EventForm onSubmit={handleSubmit} isSubmitting={isSubmitting} />
      </div>
    </div>
  )
}
