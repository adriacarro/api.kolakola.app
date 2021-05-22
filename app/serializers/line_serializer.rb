# frozen_string_literal: true

class LineSerializer < ActiveModel::Serializer
  attributes :id, :code, :position, :status, :service_id, :worker, :service

  def service
    object.service&.name
  end

  def worker
    object.worker&.name
  end
end
