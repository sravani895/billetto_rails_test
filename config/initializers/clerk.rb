Clerk.configure do |config|
  config.secret_key = ENV["CLERK_SECRET_KEY"].presence || "sk_test_dummy_build_key_12345"
  config.excluded_routes = [ "/sign_out" ]
end
