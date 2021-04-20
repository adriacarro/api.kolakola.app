# frozen_string_literal: true

class ServicePolicy < ApplicationPolicy
  def index?
    ( user.admin? || user.worker? )
  end

  def show?
    ( user.admin? || user.worker? ) && record.place_id == user.place_id
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

  def enqueue?
    user.customer?
  end
end
