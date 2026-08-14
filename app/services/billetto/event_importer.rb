module Billetto
  class EventImporter
    def initialize(user:, client: Billetto::Client.new)
      @user = user
      @client = client
    end

    def call(limit: 10)
      response = @client.public_events(limit: limit)

      response.fetch("data").map do |event_data|
        import_event(event_data)
      end
    end

    private

    def import_event(event_data)
      event = @user.events.find_or_initialize_by(
        billetto_id: event_data.fetch("id").to_s
      )

      event.assign_attributes(
        title: event_data.fetch("title"),
        description: event_data["description"],
        start_at: Time.zone.parse(event_data.fetch("startdate")),
        image_url: event_data["image_link"]
      )

      event.save!
      event
    end
  end
end
