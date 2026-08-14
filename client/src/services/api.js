const API_BASE_URL = '/api/v1'

export async function fetchEvents(params = {}) {
  const query = new URLSearchParams()
  if (params.page) query.append('page', params.page)
  if (params.per_page) query.append('per_page', params.per_page)
  if (params.search) query.append('search', params.search)
  if (params.date_from) query.append('date_from', params.date_from)
  if (params.date_to) query.append('date_to', params.date_to)
  if (params.sort) query.append('sort', params.sort)
  if (params.direction) query.append('direction', params.direction)

  const response = await fetch(`${API_BASE_URL}/events?${query.toString()}`, {
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
  })

  const data = await response.json()
  if (!response.ok) {
    throw new Error(data.error || 'Failed to fetch events')
  }

  return data
}

export async function fetchEvent(id) {
  const response = await fetch(`${API_BASE_URL}/events/${id}`, {
    headers: {
      'Accept': 'application/json'
    }
  })

  const data = await response.json()
  if (!response.ok) {
    throw new Error(data.error || 'Failed to fetch event details')
  }

  return data.data
}

export async function createEvent(eventData) {
  const response = await fetch(`${API_BASE_URL}/events`, {
    method: 'POST',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ event: eventData })
  })

  const data = await response.json()
  if (!response.ok) {
    const errorMsg = data.details ? data.details.join(', ') : (data.error || 'Failed to create event')
    throw new Error(errorMsg)
  }

  return data
}

export async function updateEvent(id, eventData) {
  const response = await fetch(`${API_BASE_URL}/events/${id}`, {
    method: 'PATCH',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ event: eventData })
  })

  const data = await response.json()
  if (!response.ok) {
    const errorMsg = data.details ? data.details.join(', ') : (data.error || 'Failed to update event')
    throw new Error(errorMsg)
  }

  return data
}

export async function deleteEvent(id) {
  const response = await fetch(`${API_BASE_URL}/events/${id}`, {
    method: 'DELETE',
    headers: {
      'Accept': 'application/json'
    }
  })

  const data = await response.json()
  if (!response.ok) {
    throw new Error(data.error || 'Failed to delete event')
  }

  return data
}
