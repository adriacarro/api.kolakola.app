class Line < ApplicationRecord
  # Relations
  belongs_to :service
  belongs_to :customer
  belongs_to :worker

  # Extensions
  acts_as_list scope: :service
end
