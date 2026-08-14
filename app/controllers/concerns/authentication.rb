module Authentication
  extend ActiveSupport::Concern

  included do
    include Clerk::Authenticatable
    helper_method :current_user if respond_to?(:helper_method)
  end

  private

  def require_clerk_user
    redirect_to clerk.sign_in_url, allow_other_host: true unless clerk.user?
  end

  def current_user
    return nil unless clerk.user?

    clerk_user = clerk.user

    @current_user ||= User.find_or_create_by!(clerk_user_id: clerk.user_id) do |user|
      user.name = [ clerk_user.first_name, clerk_user.last_name ].compact_blank.join(" ").presence || "Clerk User"
      user.email = clerk_user.email_addresses&.first&.email_address
    end
  end
end
