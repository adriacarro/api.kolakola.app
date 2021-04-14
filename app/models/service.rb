class Service < ApplicationRecord
  extend Mobility

  # Relations
  belongs_to :place
  has_many :users, -> { order(first_name: :asc) }, dependent: :destroy
  has_many :lines, dependent: :nullify

  # Extensions
  translates :name

  # Scopes
  default_scope -> { order("name->>'#{Mobility.locale}' asc") }
end
