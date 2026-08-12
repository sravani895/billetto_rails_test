class EventsController < ApplicationController
  before_action :require_clerk_user, only: [:create]
  def index
    @events = Event
      .where(start_at: Time.current..)
      .order(start_at: :asc)
  end

  def create
  end

end
