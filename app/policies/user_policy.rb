# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || record.id == user.id
  end

  def create?
    user.admin?
  end

  def update?
    user.admin? || record.id == user.id
  end

  def invite?
    user.admin?
  end

  def destroy?
    user.admin?
  end
end
