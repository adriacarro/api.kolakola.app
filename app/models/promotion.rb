class Promotion < ApplicationRecord
  extend Mobility

  # Relations
  belongs_to :place

  # Extensions
  translates :title, :message
  acts_as_list scope: :place
end
