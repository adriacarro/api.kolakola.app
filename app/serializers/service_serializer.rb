# frozen_string_literal: true

class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :avg_serving_time
end
