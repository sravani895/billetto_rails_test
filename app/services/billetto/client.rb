require "net/http"
require "uri"
require "json"

module Billetto
  class Client
    BASE_URL = "https://billetto.dk/api/v3"

    def initialize(
      api_key: ENV.fetch("BILLETTO_API_KEY"),
      api_secret: ENV.fetch("BILLETTO_API_SECRET")
    )
      @api_key = api_key
      @api_secret = api_secret
    end

    def public_events(limit: 10)
      uri = URI("#{BASE_URL}/public/events")
      uri.query = URI.encode_www_form(limit: limit)

      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      request["Api-Keypair"] = "#{@api_key}:#{@api_secret}"

      response = Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: uri.scheme == "https"
      ) do |http|
        http.request(request)
      end

      handle_response(response)
    end

    private

    def handle_response(response)
      case response
      when Net::HTTPSuccess
        JSON.parse(response.body)
      else
        raise "Billetto API request failed: #{response.code} #{response.body}"
      end
    end
  end
end
