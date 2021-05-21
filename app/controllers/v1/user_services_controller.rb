class V1::UserServicesController < ApplicationController
  before_action :find_user
  before_action :find_service

  # POST /user_services
  def create
    UserService.create!(user_id: @user.id, service_id: @service.id, current_user_id: current_user.id)
    render json: @service, status: :ok
  end

  # DELETE /user_services/{id}
  def destroy
    UserService.find_by(user_id: @user.id, service_id: @service.id)&.destroy
    head :no_content
  end

  private

    def find_user
      @user = User.find_by!(id: params[:user_id])
      # authorize @user
    end

    def find_service
      @service = Service.find_by!(id: params[:id])
      # authorize @service
    end
end
