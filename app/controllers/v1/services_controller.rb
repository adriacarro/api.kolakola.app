# frozen_string_literal: true

class V1::ServicesController < ApplicationController
  before_action :find_service, except: %i[create index]

  # GET /services
  def index
    @pagy, @services = pagy(filtered_services, items: pagination_limit)
    render json: @services, meta: pagination(@pagy), root: 'data', adapter: :json, status: :ok
  end

  # GET /services/{id}
  def show
    render json: @service, status: :ok
  end

  # POST /services
  def create
    @service = Service.create!(service_params.merge(place_id: current_user.place.id, current_user_id: current_user.id))
    render json: @service, status: :ok
  end

  # PUT /services/{id}
  def update
    @service.update!(service_params.merge(current_user_id: current_user.id))
    @service.broadcast
    render json: @service, status: :ok
  end

  # DELETE /services/{id}
  def destroy
    @service.destroy
    head :no_content
  end

  # POST /services/{id}/enqueue
  def enqueue
    @line = @service.lines.where(customer_id: current_user.id).active.first || @service.lines.create!(customer_id: current_user.id, status: :waiting, current_user_id: current_user.id)
    render json: @line, status: :ok
  end

  private
    def find_service
      @service = Service.find_by!(id: params[:id])
      authorize @service
    end

    def filtered_services
      authorize Service
      services = current_user.place.services
      services = services.search(params[:q]) if params[:q].present?
      services
    end

    def service_params
      params.require(:service).permit(:name, :avg_serving_time)
    end
end
