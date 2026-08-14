require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid user is valid" do
    user = User.new(clerk_user_id: "clerk_unique_123", name: "Alice", email: "alice@example.com")
    assert user.valid?
  end

  test "invalid without clerk_user_id" do
    user = User.new(clerk_user_id: nil)
    assert_not user.valid?
    assert_includes user.errors[:clerk_user_id], "can't be blank"
  end

  test "invalid with duplicate clerk_user_id" do
    user = User.new(clerk_user_id: @user.clerk_user_id)
    assert_not user.valid?
    assert_includes user.errors[:clerk_user_id], "has already been taken"
  end

  test "destroying user deletes associated events" do
    event_ids = @user.events.pluck(:id)
    assert_not_empty event_ids

    assert_difference "Event.count", -event_ids.size do
      @user.destroy
    end

    event_ids.each do |event_id|
      assert_not Event.exists?(event_id), "Event #{event_id} should have been destroyed"
    end
  end
end
