require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "valid event is valid" do
    event = Event.new(
      title: "Valid Concert",
      start_at: Time.current,
      billetto_id: "BLT-TEST-VALID-01",
      user: @user
    )
    assert event.valid?
  end

  test "invalid without title" do
    event = Event.new(
      title: nil,
      start_at: Time.current,
      billetto_id: "BLT-TEST-NO-TITLE",
      user: @user
    )
    assert_not event.valid?
    assert_includes event.errors[:title], "can't be blank"
  end

  test "invalid without start_at" do
    event = Event.new(
      title: "No Date Event",
      start_at: nil,
      billetto_id: "BLT-TEST-NO-DATE",
      user: @user
    )
    assert_not event.valid?
    assert_includes event.errors[:start_at], "can't be blank"
  end

  test "invalid without billetto_id" do
    event = Event.new(
      title: "No ID Event",
      start_at: Time.current,
      billetto_id: nil,
      user: @user
    )
    assert_not event.valid?
    assert_includes event.errors[:billetto_id], "can't be blank"
  end

  test "invalid with duplicate billetto_id" do
    existing_event = events(:one)
    event = Event.new(
      title: "Duplicate ID Event",
      start_at: Time.current,
      billetto_id: existing_event.billetto_id,
      user: @user
    )
    assert_not event.valid?
    assert_includes event.errors[:billetto_id], "has already been taken"
  end

  test "invalid without user" do
    event = Event.new(
      title: "Orphan Event",
      start_at: Time.current,
      billetto_id: "BLT-ORPHAN"
    )
    assert_not event.valid?
    assert_includes event.errors[:user], "must exist"
  end
end
