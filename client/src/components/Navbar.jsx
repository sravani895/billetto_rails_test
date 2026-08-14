import React from 'react'
import { Link, useLocation } from 'react-router-dom'
import { Calendar, Plus, User as UserIcon } from 'lucide-react'
import { SignedIn, SignedOut, UserButton, SignInButton } from '@clerk/clerk-react'

export default function Navbar() {
  const location = useLocation()

  return (
    <header className="navbar">
      <div className="navbar-container">
        <Link to="/" className="navbar-brand">
          <Calendar className="brand-icon" />
          <span className="brand-title">Billetto Events</span>
        </Link>

        <nav className="navbar-nav">
          <SignedIn>
            <Link
              to="/"
              className={`nav-link ${location.pathname === '/' ? 'active' : ''}`}
            >
              Events
            </Link>
            <Link
              to="/events/new"
              className="btn btn-primary btn-sm btn-icon"
            >
              <Plus size={16} />
              <span>New Event</span>
            </Link>
            <Link
              to="/profile"
              className={`nav-link ${location.pathname === '/profile' ? 'active' : ''}`}
            >
              <UserIcon size={18} />
              <span>Profile</span>
            </Link>
            <UserButton afterSignOutUrl="/" />
          </SignedIn>
          <SignedOut>
            <SignInButton mode="modal">
              <button className="btn btn-primary">Sign In</button>
            </SignInButton>
          </SignedOut>
        </nav>
      </div>
    </header>
  )
}
