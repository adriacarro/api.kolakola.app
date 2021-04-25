# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at
  attribute :invite_accepted, if: :is_worker?
  attribute :invited_at, if: :is_worker?
  belongs_to :place, unless: :is_customer?
  attribute :cookie, if: :is_customer?
  has_many :lines, if: :is_customer?

  def is_worker?
    object.worker?
  end

  def is_customer?
    object.customer?
  end
end