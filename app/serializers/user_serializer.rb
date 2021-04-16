# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :role, :email, :invite_accepted, :invited_at, :created_at

  def invited_at
    object.invited_at
  end

  def created_at
    object.created_at
  end
end
