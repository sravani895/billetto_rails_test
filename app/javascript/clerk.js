// Initialize Clerk JS SDK on page load
const ensureClerkLoaded = async () => {
  const clerk = window.Clerk || window.clerk
  if (clerk && !clerk.isReady && typeof clerk.load === "function") {
    try {
      await clerk.load()
      console.log("Clerk JS SDK loaded and ready")
    } catch (err) {
      console.error("Error initializing Clerk JS SDK:", err)
    }
  }
  return clerk
}

document.addEventListener("DOMContentLoaded", ensureClerkLoaded)
document.addEventListener("turbo:load", ensureClerkLoaded)

document.addEventListener("click", async (event) => {
  const button = event.target.closest("#clerk-sign-out")

  if (!button) return

  event.preventDefault()

  console.log("Sign out clicked")

  button.style.pointerEvents = "none"
  button.style.opacity = "0.5"
  button.textContent = "Signing out..."

  const redirectToServerSignOut = () => {
    window.location.href = "/sign_out"
  }

  const timeoutId = setTimeout(() => {
    console.warn("Clerk signOut network timeout reached, redirecting to /sign_out")
    redirectToServerSignOut()
  }, 5000)

  try {
    const clerk = await ensureClerkLoaded()

    if (clerk && typeof clerk.signOut === "function") {
      console.log("Executing Clerk.signOut()...")
      await clerk.signOut()
      console.log("Clerk JS SDK signed out successfully")
    } else {
      console.warn("Clerk SDK instance not ready or signOut method missing")
    }
  } catch (error) {
    console.error("Sign out error via JS SDK:", error)
  } finally {
    clearTimeout(timeoutId)
    redirectToServerSignOut()
  }
})