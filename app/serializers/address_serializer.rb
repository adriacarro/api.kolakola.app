# frozen_string_literal: true

class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :code, :street_1, :street_2, :city, :state, :zip_code, :country_code
end
