class ClerkWebhookJob < ApplicationJob
  queue_as :default

  def perform(payload_json)
    event = JSON.parse(payload_json)
    event_type = event["type"]
    data = event["data"] || {}

    case event_type
    when "user.created", "user.updated"
      handle_user_upsert(data)
    when "user.deleted"
      handle_user_delete(data)
    end
  end

  private

  def handle_user_upsert(data)
    data = data.with_indifferent_access
    clerk_user_id = data[:id]
    return if clerk_user_id.blank?

    email_addresses = Array(data[:email_addresses]).map { |e| e.is_a?(Hash) ? e.with_indifferent_access : e }
    primary_email_id = data[:primary_email_address_id]

    primary_obj = email_addresses.find { |e| e.is_a?(Hash) && e[:id] == primary_email_id } if primary_email_id.present?
    first_obj = email_addresses.first

    email = primary_obj&.dig(:email_address) ||
            (first_obj.is_a?(Hash) ? first_obj[:email_address] : nil) ||
            (first_obj.is_a?(String) ? first_obj : nil)

    first_name = data[:first_name]
    last_name = data[:last_name]
    name = [ first_name, last_name ].compact_blank.join(" ").presence || "Clerk User"

    user = User.find_or_initialize_by(clerk_user_id: clerk_user_id)
    user.email = email
    user.name = name
    user.save!
  end

  def handle_user_delete(data)
    data = data.with_indifferent_access
    clerk_user_id = data[:id]
    return if clerk_user_id.blank?

    user = User.find_by(clerk_user_id: clerk_user_id)
    user&.destroy!
  end
end
