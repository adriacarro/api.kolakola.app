# frozen_string_literal: true

class LinePolicy < ApplicationPolicy
  def yield?
    user.customer?
  end

  def update?
    user.worder? || user.customer?
  end

  def destroy?
    user.customer?
  end
end
