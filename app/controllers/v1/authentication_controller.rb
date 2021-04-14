# frozen_string_literal: true

class V1::AuthenticationController < ApplicationController
  skip_before_action :authorize_request

  # POST /auth/login
  def login
    @user = User.send(params.require(:platform)).find_by('lower(email) = ?', params.require(:email).downcase)
    raise ActiveModel::ValidationError.new(User.not_found) unless @user

    @user.authenticate!(params.require(:password), params.require(:platform))
    render json: login_json, status: :ok
  end

  # POST /auth/signup
  def signup
    @user = User.find_by!(invite_token: params.require(:token))
    @user.update!(send("signup_params_#{params.require(:platform)}").merge(invite_token: nil, invite_accepted: true, invite_accepted_at: Time.now))
    App::AuthMailer.welcome(@user).deliver_later
    render json: login_json, status: :ok
  end

  # GET /auth/token_validator?token_type=signup&token=fdhfdjsf
  def token_validator
    render json: token_validator_content(params[:token_type]), status: send("validate_#{params[:token_type]}_token")
  end

  # POST /users/forgot_password
  def forgot_password
    @user = User.send(params.require(:platform)).find_by!('lower(email) = ?', params.require(:email).downcase)
    authorize @user, policy_class: AuthPolicy
    @user.reset_password!
  end

  # POST /users/reset_password
  def reset_password
    @user = User.find_by!(reset_password_token: params.require(:token), platform: params.require(:platform))
    raise ActiveRecord::RecordNotFound.new(model: 'User') if @user.reset_password_expired?
    @user.update!(reset_password_params)

    render json: login_json, status: :ok
  end

  private
    def login_params
      params.permit(:email, :password, :platform)
    end

    def login_json
      token = JsonWebToken.encode({ user: { id: @user.id, email: @user.email, role: @user.role, vet: @user&.vet&.to_json } })
      time = Time.now + 24.hours.to_i
      { token: token, exp: time.strftime('%m-%d-%Y %H:%M'), user: { id: @user.id, role: @user.role, name: @user.name, email: @user.email, vet: @user&.vet&.to_json } }
    end

    def signup_params_vetapp
      params[:vet_attributes][:id] = @user.vet_id if @user.vet_manager? && params.key?(:vet_attributes)
      params.permit(:password, vet_attributes: [:id, :comercial_name, :comercial_address, :comercial_postal_code, :comercial_province, :comercial_city, :comercial_phone, :fiscal_name, :fiscal_address, :fiscal_postal_code, :fiscal_province, :fiscal_city, :fiscal_cif, :fiscal_iban, :manual_billing, :irpf_withholding])
    end

    def signup_params_xml_posting
      params.permit(:password)
    end

    def reset_password_params
      params.permit(:password, :password_confirmation)
    end

    def validate_signup_token
      User.exists?(invite_token: params[:token]) ? 200 : 403
    end

    def validate_reset_password_token
      user = User.find_by(reset_password_token: params[:token])
      return 200 if user && !user.reset_password_expired?
      403
    end

    def token_validator_content(token_type)
      return { onboarding: false } unless token_type == 'signup'
      user = User.find_by(invite_token: params[:token])
      return { onboarding: false } if user.nil? || !user.vet_manager?
      { onboarding: user.vet.status != 'active' }
    end

    def validate_auth_token
      decoded = JsonWebToken.decode(params[:token])
      User.exists?(id: decoded[:user][:id]) ? 200 : 403
    rescue JWT::VerificationError
      403
    end
end
