# frozen_string_literal: true

class ServiceSerializer < ActiveModel::Serializer
  attributes :id, :name, :avg_serving_time
  has_many :lines do
    object.lines.not_served.not_abandoned
  end
end
