import React from 'react'
import { Link } from 'react-router-dom'
import { Calendar, Tag, Edit, Trash2, ExternalLink } from 'lucide-react'

export default function EventCard({ event, onDelete }) {
  const formattedDate = new Date(event.start_at).toLocaleDateString('en-US', {
    weekday: 'short',
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })

  return (
    <div className="event-card">
      {event.image_url ? (
        <div className="event-card-image" style={{ backgroundImage: `url(${event.image_url})` }} />
      ) : (
        <div className="event-card-image-placeholder">
          <Calendar size={48} className="placeholder-icon" />
        </div>
      )}

      <div className="event-card-body">
        <div className="event-badge">
          <Tag size={12} />
          <span>{event.billetto_id}</span>
        </div>

        <h3 className="event-title">{event.title}</h3>

        <div className="event-meta">
          <Calendar size={14} />
          <span>{formattedDate}</span>
        </div>

        {event.description && (
          <p className="event-description">
            {event.description.length > 100
              ? `${event.description.substring(0, 100)}...`
              : event.description}
          </p>
        )}

        <div className="event-card-actions">
          <Link to={`/events/${event.id}`} className="btn btn-secondary btn-sm btn-icon">
            <ExternalLink size={14} />
            <span>View</span>
          </Link>
          <Link to={`/events/${event.id}/edit`} className="btn btn-outline btn-sm btn-icon">
            <Edit size={14} />
            <span>Edit</span>
          </Link>
          <button
            onClick={() => onDelete(event.id)}
            className="btn btn-danger-outline btn-sm btn-icon"
          >
            <Trash2 size={14} />
            <span>Delete</span>
          </button>
        </div>
      </div>
    </div>
  )
}
