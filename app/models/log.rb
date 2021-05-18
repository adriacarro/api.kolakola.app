class Log < ApplicationRecord
  # Relations
  belongs_to :loggable, polymorphic: true
  belongs_to :user

  # Attributes
  enum action: %i[created updated deleted]
end
