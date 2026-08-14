require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should destroy session and redirect to root" do
    get sign_out_url
    assert_redirected_to root_path
  end
end
