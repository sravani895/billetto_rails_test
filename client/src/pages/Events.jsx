import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { Search, ArrowUpDown, Calendar, Plus, RefreshCw } from 'lucide-react'
import { fetchEvents, deleteEvent } from '../services/api'
import EventCard from '../components/EventCard'
import Pagination from '../components/Pagination'
import Alert from '../components/Alert'

export default function Events() {
  const [events, setEvents] = useState([])
  const [pagination, setPagination] = useState(null)
  const [loading, setLoading] = useState(true)
  const [alert, setAlert] = useState(null)

  const [search, setSearch] = useState('')
  const [dateFrom, setDateFrom] = useState('')
  const [dateTo, setDateTo] = useState('')
  const [sort, setSort] = useState('created_at')
  const [direction, setDirection] = useState('desc')
  const [page, setPage] = useState(1)

  const loadEvents = async () => {
    setLoading(true)
    try {
      const data = await fetchEvents({
        page,
        per_page: 6,
        search,
        date_from: dateFrom,
        date_to: dateTo,
        sort,
        direction
      })
      setEvents(data.events || [])
      setPagination(data.pagination || null)
    } catch (err) {
      setAlert({ type: 'error', message: err.message })
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadEvents()
  }, [page, sort, direction])

  const handleSearchSubmit = (e) => {
    e.preventDefault()
    setPage(1)
    loadEvents()
  }

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this event?')) return

    try {
      await deleteEvent(id)
      setAlert({ type: 'success', message: 'Event deleted successfully' })
      loadEvents()
    } catch (err) {
      setAlert({ type: 'error', message: err.message })
    }
  }

  return (
    <div className="page-container">
      <div className="page-header">
        <div>
          <h1 className="page-title">Events Dashboard</h1>
          <p className="page-subtitle">Manage your scheduled events and ticketing details</p>
        </div>
        <Link to="/events/new" className="btn btn-primary btn-icon">
          <Plus size={18} />
          <span>New Event</span>
        </Link>
      </div>

      <Alert
        type={alert?.type}
        message={alert?.message}
        onClose={() => setAlert(null)}
      />

      <div className="filter-bar">
        <form onSubmit={handleSearchSubmit} className="search-form">
          <div className="search-input-wrapper">
            <Search className="search-icon" size={18} />
            <input
              type="text"
              placeholder="Search events by title or description..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="search-input"
            />
          </div>
          <button type="submit" className="btn btn-secondary btn-icon">
            <Search size={16} />
            <span>Search</span>
          </button>
        </form>

        <div className="filter-controls">
          <div className="date-filter">
            <Calendar size={16} className="filter-icon" />
            <input
              type="date"
              value={dateFrom}
              onChange={(e) => { setDateFrom(e.target.value); setPage(1); }}
              className="date-input"
              title="From date"
            />
            <span>to</span>
            <input
              type="date"
              value={dateTo}
              onChange={(e) => { setDateTo(e.target.value); setPage(1); }}
              className="date-input"
              title="To date"
            />
          </div>

          <div className="sort-control">
            <ArrowUpDown size={16} className="filter-icon" />
            <select
              value={`${sort}-${direction}`}
              onChange={(e) => {
                const [s, d] = e.target.value.split('-')
                setSort(s)
                setDirection(d)
                setPage(1)
              }}
              className="sort-select"
            >
              <option value="created_at-desc">Newest First</option>
              <option value="created_at-asc">Oldest First</option>
              <option value="start_at-asc">Start Date (Ascending)</option>
              <option value="start_at-desc">Start Date (Descending)</option>
              <option value="title-asc">Title (A-Z)</option>
              <option value="title-desc">Title (Z-A)</option>
            </select>
          </div>
        </div>
      </div>

      {loading ? (
        <div className="loading-state">
          <RefreshCw className="spin-icon" size={32} />
          <p>Loading events...</p>
        </div>
      ) : events.length === 0 ? (
        <div className="empty-state">
          <Calendar size={48} className="empty-icon" />
          <h3>No Events Found</h3>
          <p>Get started by creating your first event or adjusting your search filters.</p>
          <Link to="/events/new" className="btn btn-primary btn-icon mt-4">
            <Plus size={18} />
            <span>Create Event</span>
          </Link>
        </div>
      ) : (
        <>
          <div className="event-grid">
            {events.map((event) => (
              <EventCard key={event.id} event={event} onDelete={handleDelete} />
            ))}
          </div>

          <Pagination pagination={pagination} onPageChange={(p) => setPage(p)} />
        </>
      )}
    </div>
  )
}
