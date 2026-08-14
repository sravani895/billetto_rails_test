require "test_helper"
require "base64"
require "openssl"

class Webhooks::ClerkControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @webhook_secret = "whsec_" + Base64.strict_encode64("test_webhook_secret_key_123456")
    @user = users(:one)
  end

  test "valid webhook enqueues ClerkWebhookJob and returns 200 OK" do
    payload_hash = {
      type: "user.created",
      data: {
        id: "user_clerk_webhook_enqueue_100",
        first_name: "Enqueued",
        last_name: "User",
        email_addresses: [ { email_address: "enqueue@example.com" } ]
      }
    }
    payload = payload_hash.to_json
    headers = generate_svix_headers(payload, @webhook_secret).merge("CONTENT_TYPE" => "application/json")

    ENV["CLERK_WEBHOOK_SECRET"] = @webhook_secret
    begin
      assert_enqueued_with(job: ClerkWebhookJob, args: [ payload ]) do
        post webhooks_clerk_url, params: payload, headers: headers
      end

      assert_response :success
      assert_equal "success", JSON.parse(response.body)["status"]
    ensure
      ENV.delete("CLERK_WEBHOOK_SECRET")
    end
  end

  test "rejects webhook request with invalid signature when CLERK_WEBHOOK_SECRET is set" do
    payload = { type: "user.created", data: { id: "user_unauthorized" } }.to_json
    bad_headers = {
      "CONTENT_TYPE" => "application/json",
      "svix-id" => "msg_bad",
      "svix-timestamp" => Time.current.to_i.to_s,
      "svix-signature" => "v1,invalid_signature_hash"
    }

    ENV["CLERK_WEBHOOK_SECRET"] = @webhook_secret
    begin
      assert_no_enqueued_jobs do
        post webhooks_clerk_url, params: payload, headers: bad_headers
      end

      assert_response :unauthorized
      assert_equal "Invalid webhook signature", JSON.parse(response.body)["error"]
    ensure
      ENV.delete("CLERK_WEBHOOK_SECRET")
    end
  end

  test "rejects webhook request with invalid JSON body" do
    invalid_json_payload = "NOT_A_JSON_STRING"
    headers = generate_svix_headers(invalid_json_payload, @webhook_secret).merge("CONTENT_TYPE" => "application/json")

    ENV["CLERK_WEBHOOK_SECRET"] = @webhook_secret
    begin
      assert_no_enqueued_jobs do
        post webhooks_clerk_url, params: invalid_json_payload, headers: headers
      end

      assert_response :bad_request
      assert_includes JSON.parse(response.body)["error"], "Invalid JSON payload"
    ensure
      ENV.delete("CLERK_WEBHOOK_SECRET")
    end
  end

  private

  def generate_svix_headers(payload, secret)
    svix_id = "msg_#{SecureRandom.hex(12)}"
    svix_timestamp = Time.current.to_i.to_s
    secret_bytes = secret.start_with?("whsec_") ? Base64.decode64(secret.sub("whsec_", "")) : secret
    to_sign = "#{svix_id}.#{svix_timestamp}.#{payload}"
    signature = Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", secret_bytes, to_sign))

    {
      "svix-id" => svix_id,
      "svix-timestamp" => svix_timestamp,
      "svix-signature" => "v1,#{signature}"
    }
  end
end
