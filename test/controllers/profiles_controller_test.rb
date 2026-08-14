require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect to sign in when unauthenticated" do
    get profile_url
    assert_response :redirect
  end
end
