Clerk.configure do |config|
  config.secret_key = ENV.fetch("CLERK_SECRET_KEY")
  config.excluded_routes = [ "/sign_out" ]
end
