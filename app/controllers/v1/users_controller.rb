# frozen_string_literal: true

class V1::UsersController < ApplicationController
  before_action :find_user, except: %i[create index]

  # GET /users
  def index
    @pagy, @users = pagy(filtered_users, items: pagination_limit)
    render json: @users, meta: pagination(@pagy), root: 'data', adapter: :json, status: :ok
  end

  # GET /users/{id}
  def show
    render json: @user, status: :ok
  end

  # POST /users
  def create
    authorize User
    @user = User.create!(user_params.merge({place_id: current_user.place.id, role: :worker}))
  end

  # PUT /users/{id}
  def update
    @user.update!(user_params)
    @user.invite! if params[:send_invite].present? && params[:send_invite]
    render json: @user, status: :ok
  end

  # POST /users/{id}/invite
  def invite
    @user.invite!
  end

  # DELETE /users/{id}
  def destroy
    @user.destroy
  end

  private
    def find_user
      @user = User.find_by!(id: params[:id])
      authorize @user
    end

    def filtered_users
      authorize User
      users = current_user.place.users
      users = users.send(params[:type]) if params[:type].present? && ['admin', 'worker'].include?(params[:type])
      users = users.search(params[:q]) if params[:q].present?
      users = users.send(params[:status]) if params[:status].present? && ['all', 'sent', 'accepted'].include?(params[:status])
      users
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :email)
    end
end
