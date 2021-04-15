# frozen_string_literal: true

class ServicePolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? && record.place_id == user.place_id
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? && record.place_id == user.place_id
  end

  def destroy?
    user.admin? && record.place_id == user.place_id
  end
end
