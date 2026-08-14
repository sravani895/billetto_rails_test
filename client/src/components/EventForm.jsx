import React, { useState } from 'react'

export default function EventForm({ initialData = {}, onSubmit, isSubmitting }) {
  const [formData, setFormData] = useState({
    title: initialData.title || '',
    billetto_id: initialData.billetto_id || '',
    description: initialData.description || '',
    start_at: initialData.start_at
      ? new Date(initialData.start_at).toISOString().slice(0, 16)
      : '',
    image_url: initialData.image_url || ''
  })

  const handleChange = (e) => {
    const { name, value } = e.target
    setFormData((prev) => ({ ...prev, [name]: value }))
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    onSubmit(formData)
  }

  return (
    <form onSubmit={handleSubmit} className="event-form">
      <div className="form-group">
        <label htmlFor="title" className="form-label">
          Event Title *
        </label>
        <input
          id="title"
          name="title"
          type="text"
          required
          value={formData.title}
          onChange={handleChange}
          placeholder="e.g. Summer Music Festival 2026"
          className="form-input"
        />
      </div>

      <div className="form-group">
        <label htmlFor="billetto_id" className="form-label">
          Billetto ID *
        </label>
        <input
          id="billetto_id"
          name="billetto_id"
          type="text"
          required
          value={formData.billetto_id}
          onChange={handleChange}
          placeholder="e.g. BLT-10020"
          className="form-input"
        />
      </div>

      <div className="form-group">
        <label htmlFor="start_at" className="form-label">
          Start Date & Time *
        </label>
        <input
          id="start_at"
          name="start_at"
          type="datetime-local"
          required
          value={formData.start_at}
          onChange={handleChange}
          className="form-input"
        />
      </div>

      <div className="form-group">
        <label htmlFor="image_url" className="form-label">
          Banner Image URL (Optional)
        </label>
        <input
          id="image_url"
          name="image_url"
          type="url"
          value={formData.image_url}
          onChange={handleChange}
          placeholder="https://images.unsplash.com/photo-..."
          className="form-input"
        />
      </div>

      <div className="form-group">
        <label htmlFor="description" className="form-label">
          Description
        </label>
        <textarea
          id="description"
          name="description"
          rows={4}
          value={formData.description}
          onChange={handleChange}
          placeholder="Describe your event details, schedule, and guidelines..."
          className="form-textarea"
        />
      </div>

      <div className="form-actions">
        <button
          type="submit"
          disabled={isSubmitting}
          className="btn btn-primary"
        >
          {isSubmitting ? 'Saving Event...' : 'Save Event'}
        </button>
      </div>
    </form>
  )
}
