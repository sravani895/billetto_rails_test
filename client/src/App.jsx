import React from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { ClerkProvider, SignedIn, SignedOut, SignIn } from '@clerk/clerk-react'
import Navbar from './components/Navbar'
import Events from './pages/Events'
import EventDetails from './pages/EventDetails'
import NewEvent from './pages/NewEvent'
import EditEvent from './pages/EditEvent'
import Profile from './pages/Profile'
import './App.css'

const clerkPubKey = import.meta.env.VITE_CLERK_PUBLISHABLE_KEY

if (!clerkPubKey) {
  throw new Error('Missing Clerk Publishable Key. Please set VITE_CLERK_PUBLISHABLE_KEY in client/.env')
}

export default function App() {
  return (
    <ClerkProvider publishableKey={clerkPubKey}>
      <BrowserRouter>
        <div className="app-wrapper">
          <Navbar />
          <main>
            <SignedIn>
              <Routes>
                <Route path="/" element={<Events />} />
                <Route path="/events/new" element={<NewEvent />} />
                <Route path="/events/:id" element={<EventDetails />} />
                <Route path="/events/:id/edit" element={<EditEvent />} />
                <Route path="/profile" element={<Profile />} />
              </Routes>
            </SignedIn>
            <SignedOut>
              <div className="page-container" style={{ display: 'flex', justifyContent: 'center', paddingTop: '4rem' }}>
                <SignIn routing="hash" />
              </div>
            </SignedOut>
          </main>
        </div>
      </BrowserRouter>
    </ClerkProvider>
  )
}
