class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  include Clerk::Authenticatable
  # Changes to the importmap will invalidate the etag for HTML responses
  helper_method :current_user
  stale_when_importmap_changes
  private

  def require_clerk_user
    redirect_to clerk.sign_in_url, allow_other_host: true unless clerk.user?
  end
  def current_user
    return nil unless clerk.user?

    clerk_user = clerk.user

    @current_user ||= User.find_or_create_by!(clerk_user_id: clerk.user_id) do |user|
      user.name = [ clerk_user.first_name, clerk_user.last_name ].compact.join(" ")
      user.email = clerk_user.email_addresses.first.email_address
    end
  end
end
