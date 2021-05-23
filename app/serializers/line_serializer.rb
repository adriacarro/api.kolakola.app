# frozen_string_literal: true

class LineSerializer < ActiveModel::Serializer
  attributes :id, :code, :position, :status, :service_id, :worker, :service, :avg_serving_time

  def service
    object.service&.name
  end

  def avg_serving_time
    object.service&.avg_serving_time
  end

  def worker
    object.worker&.name
  end
end
