# frozen_string_literal: true

class Rating < ApplicationRecord
  include Loggable

  # Relations
  belongs_to :user, optional: true
  belongs_to :loggable, polymorphic: true, optional: true

  # Methods
  def self.avg
    return 0 if count.zero?
    sum(:value) / count.to_f
  end
end
