class Place < ApplicationRecord
  # Relations
  belongs_to :category
  belongs_to :billing_address, class_name: "Address", foreign_key: "billing_address_id"
  belongs_to :address
  has_many :users, -> { order(first_name: :asc) }, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :promotions, -> { order(position: :asc) }, dependent: :destroy
  has_many :lines, dependent: :nullify
end
