require "test_helper"

class Api::V1::EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_a = users(:one)
    @user_b = users(:two)
    @event_a = events(:one)
    @event_b = events(:two)
  end

  test "unauthenticated request to GET /api/v1/events returns 401 Unauthorized JSON" do
    get api_v1_events_url, as: :json
    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Authentication required", json_response["error"]
  end

  test "GET /api/v1/events returns current_user's events and pagination metadata" do
    sign_in_as(@user_a)

    get api_v1_events_url, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    events_data = json_response["events"]
    pagination = json_response["pagination"]

    assert_kind_of Array, events_data
    event_ids = events_data.map { |e| e["id"] }

    assert_includes event_ids, @event_a.id
    assert_not_includes event_ids, @event_b.id

    assert_equal 1, pagination["page"]
    assert_equal 10, pagination["per_page"]
    assert_equal 1, pagination["total"]
    assert_equal 1, pagination["total_pages"]
  end

  test "GET /api/v1/events handles custom page and per_page parameters" do
    sign_in_as(@user_a)

    # Create additional events for user_a
    Event.create!(user: @user_a, title: "Second Event", start_at: Time.current + 1.day, billetto_id: "BLT-PAG-01")
    Event.create!(user: @user_a, title: "Third Event", start_at: Time.current + 2.days, billetto_id: "BLT-PAG-02")

    get api_v1_events_url, params: { page: 1, per_page: 2 }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 2, json_response["events"].size
    assert_equal 1, json_response["pagination"]["page"]
    assert_equal 2, json_response["pagination"]["per_page"]
    assert_equal 3, json_response["pagination"]["total"]
    assert_equal 2, json_response["pagination"]["total_pages"]
  end

  test "GET /api/v1/events filters events by case-insensitive search term" do
    sign_in_as(@user_a)
    Event.create!(user: @user_a, title: "Rock Music Concert", description: "Rock festival", start_at: Time.current + 1.day, billetto_id: "BLT-SEARCH-01")

    get api_v1_events_url, params: { search: "ROCK" }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    events_data = json_response["events"]
    assert_equal 1, events_data.size
    assert_equal "Rock Music Concert", events_data.first["title"]
  end

  test "GET /api/v1/events filters events by start_at date range" do
    sign_in_as(@user_a)
    past_event = Event.create!(user: @user_a, title: "Past Event", start_at: "2026-01-01 10:00:00", billetto_id: "BLT-DATE-01")
    future_event = Event.create!(user: @user_a, title: "Future Event", start_at: "2026-12-01 10:00:00", billetto_id: "BLT-DATE-02")

    get api_v1_events_url, params: { date_from: "2026-11-01", date_to: "2026-12-31" }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    event_ids = json_response["events"].map { |e| e["id"] }

    assert_includes event_ids, future_event.id
    assert_not_includes event_ids, past_event.id
  end

  test "GET /api/v1/events orders events by specified sort column and direction" do
    sign_in_as(@user_a)
    event_early = Event.create!(user: @user_a, title: "Alpha Early", start_at: Time.current + 1.day, billetto_id: "BLT-SORT-01")
    event_late = Event.create!(user: @user_a, title: "Zeta Late", start_at: Time.current + 10.days, billetto_id: "BLT-SORT-02")

    get api_v1_events_url, params: { sort: "start_at", direction: "asc" }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    titles = json_response["events"].map { |e| e["title"] }
    assert_operator titles.index(event_early.title), :<, titles.index(event_late.title)
  end

  test "GET /api/v1/events returns empty list and zero totals when no match is found" do
    sign_in_as(@user_a)

    get api_v1_events_url, params: { search: "NonExistentKeyword999" }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_empty json_response["events"]
    assert_equal 0, json_response["pagination"]["total"]
    assert_equal 0, json_response["pagination"]["total_pages"]
  end

  test "GET /api/v1/events/:id returns details for owner's event in standardized data key" do
    sign_in_as(@user_a)

    get api_v1_event_url(@event_a), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @event_a.id, json_response["data"]["id"]
    assert_equal @event_a.title, json_response["data"]["title"]
  end

  test "GET /api/v1/events/:id returns 404 Not Found JSON when requesting another user's event" do
    sign_in_as(@user_a)

    get api_v1_event_url(@event_b), as: :json
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_equal "Event not found", json_response["error"]
  end

  test "POST /api/v1/events creates event bound to current_user and returns standardized 201 Created JSON" do
    sign_in_as(@user_a)

    assert_difference "Event.count", 1 do
      post api_v1_events_url, params: {
        event: {
          title: "API Created Festival",
          start_at: Time.current + 2.days,
          billetto_id: "BLT-API-001",
          description: "Created via JSON API"
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    created_event = json_response["data"]

    assert_equal "API Created Festival", created_event["title"]
    assert_equal "Event created successfully", json_response["message"]
    assert_equal @user_a.id, created_event["user_id"]
  end

  test "POST /api/v1/events with invalid params returns standardized 422 Unprocessable Entity JSON" do
    sign_in_as(@user_a)

    assert_no_difference "Event.count" do
      post api_v1_events_url, params: {
        event: {
          title: "", # invalid blank title
          start_at: nil,
          billetto_id: ""
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "Validation failed", json_response["error"]
    assert_kind_of Array, json_response["details"]
    assert_not_empty json_response["details"]
  end

  test "PATCH /api/v1/events/:id updates event and returns standardized 200 OK JSON" do
    sign_in_as(@user_a)

    patch api_v1_event_url(@event_a), params: {
      event: {
        title: "API Updated Title"
      }
    }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "API Updated Title", json_response["data"]["title"]
    assert_equal "Event updated successfully", json_response["message"]
    assert_equal "API Updated Title", @event_a.reload.title
  end

  test "PATCH /api/v1/events/:id with invalid params returns standardized 422 Unprocessable Entity JSON" do
    sign_in_as(@user_a)

    patch api_v1_event_url(@event_a), params: {
      event: {
        title: ""
      }
    }, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "Validation failed", json_response["error"]
    assert_kind_of Array, json_response["details"]
  end

  test "DELETE /api/v1/events/:id destroys event and returns standardized 200 OK JSON" do
    sign_in_as(@user_a)
    event_id = @event_a.id

    assert_difference "Event.count", -1 do
      delete api_v1_event_url(@event_a), as: :json
    end

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "Event deleted successfully", json_response["message"]
    assert_not Event.exists?(event_id)
  end
end
