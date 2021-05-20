# frozen_string_literal: true

class UserService < ApplicationRecord
  include Loggable
  
  belongs_to :user
  belongs_to :service
end
