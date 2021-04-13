class Place < ApplicationRecord
  # Relations
  belongs_to :category
  belongs_to :billing_address
  belongs_to :address
  has_many :services, dependent: :destroy
  has_many :promotions, -> { order(position: :asc) }, dependent: :destroy
  has_many :lines, dependent: :nullify
end
