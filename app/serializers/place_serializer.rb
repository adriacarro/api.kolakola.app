# frozen_string_literal: true

class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :name
  belongs_to :category
  belongs_to :billing_address, if: :admin?
  belongs_to :address
  has_many :services

  def admin?
    @instance_options[:user].admin?
  end
end
