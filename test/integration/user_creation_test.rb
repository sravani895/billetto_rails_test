require "test_helper"

class UserCreationTest < ActionDispatch::IntegrationTest
  test "creates a Rails User on first Clerk authentication" do
    new_clerk_user = Struct.new(:clerk_user_id, :name, :email).new(
      "user_clerk_new_999",
      "Clerk NewUser",
      "newuser@example.com"
    )

    assert_nil User.find_by(clerk_user_id: new_clerk_user.clerk_user_id)

    assert_difference "User.count", 1 do
      sign_in_as(new_clerk_user)
      get events_url
    end

    created_user = User.find_by!(clerk_user_id: new_clerk_user.clerk_user_id)
    assert_equal "Clerk NewUser", created_user.name
    assert_equal "newuser@example.com", created_user.email
  end

  test "is idempotent and does not duplicate Rails User for same Clerk ID" do
    clerk_user = Struct.new(:clerk_user_id, :name, :email).new(
      "user_clerk_repeat_888",
      "Repeat User",
      "repeat@example.com"
    )

    sign_in_as(clerk_user)
    get events_url
    first_user_id = User.find_by!(clerk_user_id: clerk_user.clerk_user_id).id

    # Second authentication request with same Clerk ID
    assert_no_difference "User.count" do
      sign_in_as(clerk_user)
      get events_url
    end

    second_user_id = User.find_by!(clerk_user_id: clerk_user.clerk_user_id).id
    assert_equal first_user_id, second_user_id
  end
end
