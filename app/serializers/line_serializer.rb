# frozen_string_literal: true

class LineSerializer < ActiveModel::Serializer
  attributes :id, :code, :position, :status, :service_id
end
