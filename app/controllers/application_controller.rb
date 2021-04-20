# frozen_string_literal: true

class ApplicationController < ActionController::API
  # include Error::ErrorHandler
  include Pundit
  include Pagy::Backend

  before_action :authorize_request

  attr_reader :current_user

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    @decoded = JsonWebToken.decode(header)
    @current_user = User.find_by!(id: @decoded[:user][:id])
  end

  def authorize_roles(roles)
    raise Pundit::NotAuthorizedError, I18n.t('pundit.default') unless roles.include?(current_user.role)
  end

  def pagination(pagy)
    {
      pagination: {
        total_items: pagy.count,
        total_pages: pagy.pages,
        items: pagy.items,
        per_page: pagy.vars[:items],
        current_page: pagy.page,
        next_page: pagy.next,
        prev_page: pagy.prev
      }
    }
  end

  def pagination_limit
    params[:limit].present? ? params[:limit].to_i : nil
  end
end
