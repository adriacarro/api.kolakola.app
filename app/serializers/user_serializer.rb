# frozen_string_literal: true

class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :created_at

  attribute :line, if: :is_worker?
  attribute :invite_accepted, if: :is_worker?
  attribute :invited_at, if: :is_worker?

  attribute :place, unless: :is_customer?
  belongs_to :service, if: :is_worker?
  
  attribute :cookie, if: :is_customer?
  has_many :lines, if: :is_customer? do
    object.lines.active
  end

  def line
    object.lines.active.any? ? ActiveModelSerializers::SerializableResource.new(object.lines.active.first).serializable_hash : nil
  end

  def place
    ActiveModelSerializers::SerializableResource.new(object.place, user: object).serializable_hash
  end

  def is_worker?
    object.worker?
  end

  def is_customer?
    object.customer?
  end
end