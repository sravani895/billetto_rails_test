class EventsController < ApplicationController
  before_action :require_clerk_user, except: %i[index]
  before_action :set_event, only: %i[show edit update destroy]

  def index
    @events = current_user ? current_user.events : Event.none
  end

  def show
  end

  def new
    @event = current_user.events.build
  end

  def create
    @event = current_user.events.build(event_params)

    if @event.save
      redirect_to @event, notice: "Event was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!

    redirect_to events_path, notice: "Event was successfully deleted."
  end

  rescue_from ActiveRecord::RecordNotFound, with: :event_not_found

  private

  def event_not_found
    redirect_to events_path, alert: "Event not found or you do not have permission to access it."
  end

  def set_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :billetto_id,
      :title,
      :description,
      :start_at,
      :image_url
    )
  end
end
