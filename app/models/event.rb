class Event < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :start_at, presence: true
  validates :billetto_id, presence: true, uniqueness: true

  scope :search_by_term, ->(term) {
    if term.present?
      where("title ILIKE :term OR description ILIKE :term", term: "%#{sanitize_sql_like(term)}%")
    end
  }

  scope :start_at_from, ->(date_str) {
    if date_str.present?
      parsed_date = Time.zone.parse(date_str) rescue nil
      where("start_at >= ?", parsed_date) if parsed_date
    end
  }

  scope :start_at_to, ->(date_str) {
    if date_str.present?
      parsed_date = Time.zone.parse(date_str) rescue nil
      where("start_at <= ?", parsed_date.end_of_day) if parsed_date
    end
  }

  scope :order_by_param, ->(sort_param, direction_param) {
    allowed_sorts = { "start_at" => :start_at, "created_at" => :created_at, "title" => :title }
    allowed_directions = %w[asc desc]

    sort_col = allowed_sorts[sort_param.to_s] || :created_at
    dir = allowed_directions.include?(direction_param.to_s.downcase) ? direction_param.to_s.downcase.to_sym : :desc

    order(sort_col => dir)
  }
end
