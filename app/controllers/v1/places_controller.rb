# frozen_string_literal: true

class V1::PlacesController < ApplicationController
  before_action :find_place

  # GET /places/{id}
  def show
    render json: @place, user: current_user, status: :ok
  end

  # PUT /places/{id}
  def update
    @place.update!(place_params)
    render json: @place, user: current_user, status: :ok
  end

  private
    def find_place
      @place = Place.find_by!(id: params[:id])
      authorize @place
    end

    def place_params
      params.require(:place).permit(:name, :category_id, address_attributes: [:name, :code, :street_1, :street_2, :city, :state, :zip_code, :country_code], billing_address_attributes: [:name, :code, :street_1, :street_2, :city, :state, :zip_code, :country_code])
    end
end
