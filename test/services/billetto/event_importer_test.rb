require "test_helper"

class Billetto::EventImporterTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "imports public events and associates them with the user" do
    fake_client = Object.new
    def fake_client.public_events(limit:)
      {
        "data" => [
          {
            "id" => "99901",
            "title" => "Imported Tech Talk",
            "description" => "A tech talk about Rails",
            "startdate" => "2026-09-01T10:00:00Z",
            "image_link" => "https://example.com/techtalk.jpg"
          }
        ]
      }
    end

    importer = Billetto::EventImporter.new(user: @user, client: fake_client)

    assert_difference -> { @user.events.count } => 1 do
      importer.call(limit: 1)
    end

    event = @user.events.find_by!(billetto_id: "99901")
    assert_equal "Imported Tech Talk", event.title
    assert_equal @user.id, event.user_id
  end
end
