import React from 'react'
import { AlertCircle, CheckCircle2 } from 'lucide-react'

export default function Alert({ type = 'error', message, onClose }) {
  if (!message) return null

  const isSuccess = type === 'success'

  return (
    <div className={`alert-banner ${isSuccess ? 'alert-success' : 'alert-error'}`}>
      <div className="alert-content">
        {isSuccess ? <CheckCircle2 className="alert-icon" /> : <AlertCircle className="alert-icon" />}
        <span>{message}</span>
      </div>
      {onClose && (
        <button onClick={onClose} className="alert-close" aria-label="Close alert">
          &times;
        </button>
      )}
    </div>
  )
}
