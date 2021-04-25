# frozen_string_literal: true

class V1::AuthenticationController < ApplicationController
  include ActionController::Cookies
  skip_before_action :authorize_request

  # POST /auth/login
  def login
    @user = User.find_by('lower(email) = ?', params.require(:email).downcase)
    raise ActiveModel::ValidationError.new(User.not_found) unless @user

    @user.authenticate!(params.require(:password))
    cookies.signed[:user_id] = @user.id unless @user.errors.any?
    render json: login_json, status: :ok
  end

  # POST /auth/guest
  def guest
    @user = params[:cookie].present? ? User.find_by!(cookie: params[:cookie]) : User.create!(role: :customer)
    cookies.signed[:user_id] = @user.id
    render json: login_json, status: :ok
  end

  # POST /auth/signup
  def signup
    @user = User.find_by!(invite_token: params.require(:token))
    @user.update!(signup_params.merge(invite_token: nil, invite_accepted: true, invite_accepted_at: Time.now))
    AuthMailer.welcome(@user).deliver_later
    render json: login_json, status: :ok
  end

  # POST /users/forgot_password
  def forgot_password
    @user = User.find_by!('lower(email) = ?', params.require(:email).downcase)
    authorize @user, policy_class: AuthPolicy
    @user.reset_password!
  end

  # POST /users/reset_password
  def reset_password
    @user = User.find_by!(reset_password_token: params.require(:token))
    raise ActiveRecord::RecordNotFound.new(model: 'User') if @user.reset_password_expired?
    @user.update!(reset_password_params)

    render json: login_json, status: :ok
  end

  private
    def login_params
      params.permit(:email, :password, :platform)
    end

    def login_json
      token = JsonWebToken.encode({ user: @user.login_json })
      time = Time.now + 24.hours.to_i
      { token: token, exp: time.strftime('%m-%d-%Y %H:%M') }
    end

    def signup_params
      params.permit(:password)
    end

    def reset_password_params
      params.permit(:password, :password_confirmation)
    end
end
