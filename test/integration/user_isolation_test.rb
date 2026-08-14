require "test_helper"

class UserIsolationTest < ActionDispatch::IntegrationTest
  setup do
    @user_a = users(:one)
    @user_b = users(:two)

    @event_a = events(:one) # belongs to user_a
    @event_b = events(:two) # belongs to user_b
  end

  test "User A and User B map to separate Rails users" do
    assert_not_equal @user_a.id, @user_b.id
    assert_not_equal @user_a.clerk_user_id, @user_b.clerk_user_id
  end

  test "User A and User B have separate events" do
    assert_includes @user_a.events, @event_a
    assert_not_includes @user_a.events, @event_b

    assert_includes @user_b.events, @event_b
    assert_not_includes @user_b.events, @event_a
  end

  test "User A sees only Event A on index page" do
    sign_in_as(@user_a)
    get events_url
    assert_response :success
    assert_select "article.event-card", text: /#{@event_a.title}/
    assert_select "article.event-card", text: /#{@event_b.title}/, count: 0
  end

  test "User B sees only Event B on index page" do
    sign_in_as(@user_b)
    get events_url
    assert_response :success
    assert_select "article.event-card", text: /#{@event_b.title}/
    assert_select "article.event-card", text: /#{@event_a.title}/, count: 0
  end

  test "User A cannot access User B's event when authenticated as User A" do
    sign_in_as(@user_a)

    get event_url(@event_b)
    assert_redirected_to events_path
    follow_redirect!
    assert_select ".alert, body", text: /Event not found or you do not have permission/
  end

  test "User B cannot access User A's event when authenticated as User B" do
    sign_in_as(@user_b)

    get event_url(@event_a)
    assert_redirected_to events_path
    follow_redirect!
    assert_select ".alert, body", text: /Event not found or you do not have permission/
  end

  test "User A cannot edit User B's event" do
    sign_in_as(@user_a)

    get edit_event_url(@event_b)
    assert_redirected_to events_path
    follow_redirect!
    assert_select ".alert, body", text: /Event not found or you do not have permission/
  end

  test "User A cannot update User B's event" do
    sign_in_as(@user_a)

    patch event_url(@event_b), params: { event: { title: "Unauthorized Title Change" } }
    assert_redirected_to events_path
    assert_equal "User B Event", @event_b.reload.title
  end

  test "User A cannot delete User B's event" do
    sign_in_as(@user_a)

    assert_no_difference "Event.count" do
      delete event_url(@event_b)
    end
    assert_redirected_to events_path
  end

  test "User A created events belong to User A and are not visible to User B" do
    sign_in_as(@user_a)

    assert_difference -> { @user_a.events.count } => 1, -> { @user_b.events.count } => 0 do
      post events_url, params: {
        event: {
          billetto_id: "USER_A_EVENT_99",
          title: "User A Private Party",
          description: "Exclusive for User A",
          start_at: Time.current
        }
      }
    end

    # Sign in as User B and verify they cannot see User A's new event
    sign_in_as(@user_b)
    get events_url
    assert_response :success
    assert_select "article.event-card", text: /User B Event/
    assert_select "article.event-card", text: /User A Private Party/, count: 0
  end
end
