module Api
  module V1
    class BaseController < ActionController::API
      include Clerk::Authenticatable

      before_action :require_clerk_api_user!

      rescue_from ActiveRecord::RecordNotFound, with: :api_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :api_validation_failed
      rescue_from ActionController::ParameterMissing, with: :api_parameter_missing

      private

      def require_clerk_api_user!
        return if clerk.user?

        render json: { error: "Authentication required" }, status: :unauthorized
      end

      def current_user
        return nil unless clerk.user?

        clerk_user = clerk.user

        @current_user ||= User.find_or_create_by!(clerk_user_id: clerk.user_id) do |user|
          user.name = [ clerk_user.first_name, clerk_user.last_name ].compact_blank.join(" ").presence || "Clerk User"
          user.email = clerk_user.email_addresses&.first&.email_address
        end
      end

      def api_not_found
        render json: { error: "Event not found" }, status: :not_found
      end

      def api_validation_failed(exception)
        render json: {
          error: "Validation failed",
          details: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end

      def api_parameter_missing(exception)
        render json: {
          error: "Parameter missing",
          details: [ exception.message ]
        }, status: :bad_request
      end
    end
  end
end
