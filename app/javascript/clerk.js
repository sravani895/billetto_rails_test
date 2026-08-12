import Clerk from "clerk"

const publishableKey = document
  .querySelector("meta[name='clerk-publishable-key']")
  ?.getAttribute("content")

if (publishableKey) {
  window.clerk = new Clerk(publishableKey)

  window.clerk.load().then(() => {
    console.log("Clerk loaded")

    document.addEventListener("click", async (event) => {
      const button = event.target.closest("#clerk-sign-out")

      if (!button) return

      console.log("Sign out clicked")

      try {
        await window.clerk.signOut()

        console.log("Successfully signed out")

        window.location.href = "/"
      } catch (error) {
        console.error("Sign out failed:", error)
      }
    })
  })
}