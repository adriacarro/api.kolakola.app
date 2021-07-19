# frozen_string_literal: true

class TinyUserSerializer < ActiveModel::Serializer
  attributes :id, :name, :active
end