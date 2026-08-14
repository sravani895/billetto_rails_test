require "base64"
require "openssl"

module Webhooks
  class ClerkController < ApplicationController
    skip_before_action :verify_authenticity_token

    def create
      payload = request.raw_post
      secret = ENV["CLERK_WEBHOOK_SECRET"]

      if secret.present? && !valid_svix_signature?(payload, request.headers, secret)
        render json: { error: "Invalid webhook signature" }, status: :unauthorized
        return
      end

      JSON.parse(payload)

      ClerkWebhookJob.perform_later(payload)

      render json: { status: "success" }, status: :ok
    rescue JSON::ParserError => e
      render json: { error: "Invalid JSON payload: #{e.message}" }, status: :bad_request
    end

    private

    def valid_svix_signature?(payload, headers, secret)
      svix_id = headers["svix-id"] || headers["HTTP_SVIX_ID"]
      svix_timestamp = headers["svix-timestamp"] || headers["HTTP_SVIX_TIMESTAMP"]
      svix_signature = headers["svix-signature"] || headers["HTTP_SVIX_SIGNATURE"]

      return false if svix_id.blank? || svix_timestamp.blank? || svix_signature.blank?

      secret_bytes = secret.start_with?("whsec_") ? Base64.decode64(secret.sub("whsec_", "")) : secret
      to_sign = "#{svix_id}.#{svix_timestamp}.#{payload}"
      expected_sig = Base64.strict_encode64(OpenSSL::HMAC.digest("SHA256", secret_bytes, to_sign))

      signatures = svix_signature.split(" ").map { |s| s.split(",", 2) }
      signatures.any? { |version, sig| version == "v1" && ActiveSupport::SecurityUtils.secure_compare(sig, expected_sig) }
    end
  end
end
