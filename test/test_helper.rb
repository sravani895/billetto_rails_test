ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  setup do
    sign_out
  end

  teardown do
    sign_out
  end

  def sign_in_as(user)
    clerk_proxy = Struct.new(:user?, :user_id, :user, :sign_in_url, :sign_up_url).new(
      true,
      user.clerk_user_id,
      Struct.new(:first_name, :last_name, :email_addresses).new(
        user.name&.split&.first || "Test",
        user.name&.split&.drop(1)&.join(" ") || "User",
        [ Struct.new(:email_address).new(user.email || "test@example.com") ]
      ),
      "https://clerk.example.com/sign_in",
      "https://clerk.example.com/sign_up"
    )

    ApplicationController.define_method(:clerk) { clerk_proxy }
    Api::V1::BaseController.define_method(:clerk) { clerk_proxy } if defined?(Api::V1::BaseController)
  end

  def sign_out
    empty_proxy = Struct.new(:user?, :user_id, :user, :sign_in_url, :sign_up_url).new(
      false, nil, nil, "https://clerk.example.com/sign_in", "https://clerk.example.com/sign_up"
    )
    ApplicationController.define_method(:clerk) { empty_proxy }
    Api::V1::BaseController.define_method(:clerk) { empty_proxy } if defined?(Api::V1::BaseController)
  end
end
