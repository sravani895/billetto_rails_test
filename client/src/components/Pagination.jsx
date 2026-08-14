import React from 'react'
import { ChevronLeft, ChevronRight } from 'lucide-react'

export default function Pagination({ pagination, onPageChange }) {
  if (!pagination || pagination.total_pages <= 1) return null

  const { page, total_pages, total } = pagination

  return (
    <div className="pagination-container">
      <div className="pagination-info">
        Showing page <strong>{page}</strong> of <strong>{total_pages}</strong> ({total} total events)
      </div>

      <div className="pagination-controls">
        <button
          onClick={() => onPageChange(page - 1)}
          disabled={page <= 1}
          className="btn btn-outline btn-sm btn-icon"
        >
          <ChevronLeft size={16} />
          <span>Previous</span>
        </button>

        <span className="pagination-current">{page}</span>

        <button
          onClick={() => onPageChange(page + 1)}
          disabled={page >= total_pages}
          className="btn btn-outline btn-sm btn-icon"
        >
          <span>Next</span>
          <ChevronRight size={16} />
        </button>
      </div>
    </div>
  )
}
