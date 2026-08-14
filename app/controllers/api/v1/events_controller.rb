module Api
  module V1
    class EventsController < BaseController
      before_action :set_event, only: %i[show update destroy]

      def index
        events_scope = current_user.events
                                  .search_by_term(params[:search])
                                  .start_at_from(params[:date_from])
                                  .start_at_to(params[:date_to])
                                  .order_by_param(params[:sort], params[:direction])

        page = [ params[:page].to_i, 1 ].max
        per_page = params[:per_page].present? ? params[:per_page].to_i.clamp(1, 50) : 10

        total_records = events_scope.count
        total_pages = total_records.positive? ? (total_records.to_f / per_page).ceil : 0

        paginated_events = events_scope.offset((page - 1) * per_page).limit(per_page)

        render json: {
          events: paginated_events,
          pagination: {
            page: page,
            per_page: per_page,
            total: total_records,
            total_pages: total_pages
          }
        }
      end

      def show
        render json: { data: @event }
      end

      def create
        @event = current_user.events.build(event_params)

        if @event.save
          render json: { data: @event, message: "Event created successfully" }, status: :created
        else
          render json: { error: "Validation failed", details: @event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @event.update(event_params)
          render json: { data: @event, message: "Event updated successfully" }, status: :ok
        else
          render json: { error: "Validation failed", details: @event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @event.destroy!
        render json: { message: "Event deleted successfully" }, status: :ok
      end

      private

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
  end
end
