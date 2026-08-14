# Idempotent seed data for system initialization
demo_user = User.find_or_create_by!(clerk_user_id: "user_demo_seed_001") do |u|
  u.name = "Demo Organizer"
  u.email = "demo.organizer@example.com"
end

[
  {
    billetto_id: "BLT-SEED-001",
    title: "Global Tech Summit 2026",
    description: "Keynotes on Cloud Native Rails, AI Agents, and Scalable Distributed Systems.",
    start_at: 7.days.from_now,
    image_url: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800"
  },
  {
    billetto_id: "BLT-SEED-002",
    title: "Indie Music & Arts Festival",
    description: "Live outdoor music performance featuring local bands and food trucks.",
    start_at: 14.days.from_now,
    image_url: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800"
  }
].each do |attrs|
  Event.find_or_create_by!(billetto_id: attrs[:billetto_id]) do |event|
    event.user = demo_user
    event.title = attrs[:title]
    event.description = attrs[:description]
    event.start_at = attrs[:start_at]
    event.image_url = attrs[:image_url]
  end
end

puts "Seeding completed: Created/verified #{User.count} user(s) and #{Event.count} event(s)."
