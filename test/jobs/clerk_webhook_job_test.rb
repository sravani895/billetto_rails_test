require "test_helper"

class ClerkWebhookJobTest < ActiveJob::TestCase
  setup do
    @user = users(:one)
  end

  test "performs user.created payload asynchronously and creates Rails user" do
    payload = {
      type: "user.created",
      data: {
        id: "user_clerk_job_created_123",
        first_name: "John",
        last_name: "JobDoe",
        primary_email_address_id: "email_1",
        email_addresses: [
          { id: "email_1", email_address: "john.jobdoe@example.com" }
        ]
      }
    }.to_json

    assert_difference "User.count", 1 do
      ClerkWebhookJob.perform_now(payload)
    end

    created_user = User.find_by!(clerk_user_id: "user_clerk_job_created_123")
    assert_equal "John JobDoe", created_user.name
    assert_equal "john.jobdoe@example.com", created_user.email
  end

  test "is idempotent when processing duplicate user.created events" do
    payload = {
      type: "user.created",
      data: {
        id: "user_clerk_duplicate_456",
        first_name: "Duplicate",
        last_name: "Test",
        email_addresses: [ { email_address: "dup@example.com" } ]
      }
    }.to_json

    # Request #1 -> Creates user
    ClerkWebhookJob.perform_now(payload)
    assert_equal 1, User.where(clerk_user_id: "user_clerk_duplicate_456").count

    # Request #2 -> Same duplicate event payload
    ClerkWebhookJob.perform_now(payload)
    assert_equal 1, User.where(clerk_user_id: "user_clerk_duplicate_456").count, "Duplicate webhook must not create a second Rails user"
  end

  test "performs user.updated payload asynchronously and updates Rails user" do
    payload = {
      type: "user.updated",
      data: {
        id: @user.clerk_user_id,
        first_name: "UpdatedJobFirst",
        last_name: "UpdatedJobLast",
        email_addresses: [ { email_address: "job_updated@example.com" } ]
      }
    }.to_json

    ClerkWebhookJob.perform_now(payload)

    @user.reload
    assert_equal "UpdatedJobFirst UpdatedJobLast", @user.name
    assert_equal "job_updated@example.com", @user.email
  end

  test "performs user.deleted payload asynchronously and purges user and events" do
    payload = {
      type: "user.deleted",
      data: {
        id: @user.clerk_user_id
      }
    }.to_json

    user_events = @user.events.pluck(:id)
    assert_not_empty user_events

    assert_difference "User.count", -1 do
      assert_difference "Event.count", -user_events.size do
        ClerkWebhookJob.perform_now(payload)
      end
    end

    assert_not User.exists?(@user.id)
    user_events.each do |event_id|
      assert_not Event.exists?(event_id)
    end
  end
end
