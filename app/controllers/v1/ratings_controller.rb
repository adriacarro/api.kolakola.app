# frozen_string_literal: true

class V1::RatingsController < ApplicationController
  # POST /ratings/{id}
  def create
    @rating = Rating.create!(rating_params.merge(current_user_id: current_user.id))
    render json: @rating, status: :ok
  end

  private
    def rating_params
      params.require(:rating).permit(:value)
    end
end
