class V1::UsersController < ApplicationController

  # GET /users
  def index
    @users = User.all
    render json: @users, root: 'data', adapter: :json, status: :ok
  end

end
