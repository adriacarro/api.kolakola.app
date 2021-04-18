# frozen_string_literal: true

class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :category, :name
  belongs_to :billing_address
  belongs_to :address
  has_many :services
end
