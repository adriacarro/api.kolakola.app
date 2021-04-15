# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :role, :email, :invited_at, :created_at

  def invited_at
    object.date_to_object(object.invited_at)
  end

  def created_at
    object.date_to_object(object.created_at)
  end
end
