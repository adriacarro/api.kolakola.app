class Category < ApplicationRecord
  extend Mobility

  # Relations
  has_many :places, dependent: :destroy

  # Extensions
  translates :name
end
