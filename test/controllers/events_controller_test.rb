require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @event = events(:one)
  end

  test "should show public welcome page on index when unauthenticated" do
    get events_url
    assert_response :success
    assert_select "h1", text: "Welcome to Billetto Events"
    assert_select "article.event-card", count: 0
  end

  test "should redirect protected routes when unauthenticated" do
    get new_event_url
    assert_response :redirect

    post events_url, params: { event: { title: "Test", start_at: Time.current, billetto_id: "BLT-UNAUTH" } }
    assert_response :redirect

    get event_url(@event)
    assert_response :redirect

    get edit_event_url(@event)
    assert_response :redirect

    patch event_url(@event), params: { event: { title: "Changed" } }
    assert_response :redirect

    delete event_url(@event)
    assert_response :redirect
  end

  test "should get index when authenticated" do
    sign_in_as(@user)
    get events_url
    assert_response :success
    assert_select "h1", text: "My Events"
  end

  test "should get new event form when authenticated" do
    sign_in_as(@user)
    get new_event_url
    assert_response :success
    assert_select "h1", text: "New Event"
  end

  test "should create event when valid" do
    sign_in_as(@user)
    assert_difference("Event.count", 1) do
      post events_url, params: {
        event: {
          title: "Fresh New Festival",
          start_at: Time.current + 1.day,
          billetto_id: "BLT-NEW-CRUDFLOW-01",
          description: "Freshly created event description."
        }
      }
    end

    created_event = Event.find_by!(billetto_id: "BLT-NEW-CRUDFLOW-01")
    assert_redirected_to event_url(created_event)
    assert_equal @user.id, created_event.user_id
  end

  test "should ignore attempted user_id parameter injection and assign event to current_user" do
    sign_in_as(@user)

    assert_difference("Event.count", 1) do
      post events_url, params: {
        event: {
          title: "Spoofed User Event",
          start_at: Time.current + 1.day,
          billetto_id: "BLT-SPOOF-01",
          user_id: @other_user.id # Attempting to forge ownership to another user
        }
      }
    end

    created_event = Event.find_by!(billetto_id: "BLT-SPOOF-01")
    assert_equal @user.id, created_event.user_id, "Event user_id must match current_user, ignoring forged user_id param"
    assert_not_equal @other_user.id, created_event.user_id
  end

  test "should render validation errors on invalid event creation" do
    sign_in_as(@user)
    assert_no_difference("Event.count") do
      post events_url, params: {
        event: {
          title: "", # invalid blank title
          start_at: nil,
          billetto_id: ""
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".form-errors, .alert-danger", text: /prohibited this event from being saved/
  end

  test "should show event details" do
    sign_in_as(@user)
    get event_url(@event)
    assert_response :success
    assert_select "h1", text: @event.title
  end

  test "should get edit event form" do
    sign_in_as(@user)
    get edit_event_url(@event)
    assert_response :success
    assert_select "h1", text: "Edit Event"
  end

  test "should update event when valid" do
    sign_in_as(@user)
    patch event_url(@event), params: {
      event: {
        title: "Updated Concert Title",
        description: "Updated description text."
      }
    }

    assert_redirected_to event_url(@event)
    assert_equal "Updated Concert Title", @event.reload.title
    assert_equal "Updated description text.", @event.description
  end

  test "should render validation errors on invalid update" do
    sign_in_as(@user)
    patch event_url(@event), params: {
      event: {
        title: ""
      }
    }

    assert_response :unprocessable_entity
    assert_select ".form-errors, .alert-danger", text: /prohibited this event from being saved/
  end

  test "should destroy event and confirm record no longer exists in DB" do
    sign_in_as(@user)
    event_id = @event.id

    assert_difference("Event.count", -1) do
      delete event_url(@event)
    end

    assert_redirected_to events_url
    assert_not Event.exists?(event_id), "Event.exists?(#{event_id}) should return false after deletion"
  end
end
