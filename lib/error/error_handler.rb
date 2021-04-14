# frozen_string_literal: true

# Error module to Handle errors globally
# include Error::ErrorHandler in application_controller.rb
module Error
  module ErrorHandler
    def self.included(klass)
      klass.class_eval do
        rescue_from StandardError do |e|
          respond(:standard_error, 500, e.to_s)
        end
        rescue_from ArgumentError do |e|
          respond(:standard_error, 422, e.to_s)
        end
        rescue_from Pundit::NotAuthorizedError do |e|
          policy_name = e.policy.class.to_s.underscore
          respond(:unauthorized, 401, I18n.t("#{policy_name}.#{e.query}", scope: 'pundit', default: :default))
        end
        rescue_from JWT::DecodeError do |e|
          respond(:unauthorized, 401, I18n.t('decode_error', scope: 'jwt'))
        end
        rescue_from JWT::ExpiredSignature do |e|
          respond(:unauthorized, 401, I18n.t('expired_signature', scope: 'jwt'))
        end
        rescue_from JWT::ImmatureSignature do |e|
          respond(:unauthorized, 401, I18n.t('immature_signature', scope: 'jwt'))
        end
        rescue_from JWT::InvalidIssuerError do |e|
          respond(:unauthorized, 401, I18n.t('invalid_issuer_error', scope: 'jwt'))
        end
        rescue_from ActiveRecord::RecordNotFound do |e|
          respond(:record_not_found, 404, I18n.t('record_not_found', model: I18n.t(e.model, scope: 'model'), scope: 'activerecord'))
        end
        # rescue_from ActiveRecord::ActiveRecordError do |e|
        #   respond(e.error, 422, e.to_s)
        # end
        rescue_from ActionController::ParameterMissing do |e|
          respond(:unprocessable_entity, 422, I18n.t('parameter_missing', param: e.param, scope: 'action_controller'))
        end
        rescue_from ActiveModel::ValidationError do |e|
          respond(:unprocessable_entity, 422, I18n.t('activerecord.errors.messages.validation_failed'), ErrorSerializer.serialize(e.model))
        end
        rescue_from ActiveRecord::RecordInvalid do |e|
          respond(:unprocessable_entity, 422, I18n.t('activerecord.errors.messages.validation_failed'), ErrorSerializer.serialize(e.record))
        end
        rescue_from AuthorizationError do |e|
          respond(e.error, e.status, e.message)
        end
      end
    end

    private
      def respond(_error, _status, _message, _errors = [])
        json = Helpers::Render.json(_error, _status, _message, _errors)
        render json: json, status: _status
      end
  end
end
