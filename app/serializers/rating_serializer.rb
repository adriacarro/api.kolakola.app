# frozen_string_literal: true

class RatingSerializer < ActiveModel::Serializer
  attributes :value, :avg

  def avg
    Rating.avg
  end
end
