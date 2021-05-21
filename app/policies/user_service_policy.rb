# frozen_string_literal: true

class UserServicePolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  def update?
    (user.admin? && user.place_id == record.place_id) || record.id == user.id
  end

  def invite?
    user.admin? && user.place_id == record.place_id
  end

  def break?
    user.admin? && user.place_id == record.place_id
  end

  def destroy?
    user.admin? && user.place_id == record.place_id
  end
end
