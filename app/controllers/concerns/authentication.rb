def require_clerk_user!
  return if clerk.user?

  redirect_to clerk.sign_in_url
end