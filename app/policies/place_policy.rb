# frozen_string_literal: true

class PlacePolicy < ApplicationPolicy
  def show?
    user.customer? || user.place_id == record.id
  end

  def update?
    user.admin? && user.place_id == record.id
  end
end
