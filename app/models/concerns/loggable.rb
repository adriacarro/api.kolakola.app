module Loggable
  extend ActiveSupport::Concern

  included do
    # Attribute to track who performs each action
    attr_accessor :current_user_id

    # Relatio{action: action, user_id: current_user_id, log_changes: changes_to_log}ns
    has_many :logs, as: :loggable, dependent: :destroy

    # Callback for creates and updates
    after_create -> { track_log(action: :created) }
    after_update -> { track_log(action: :updated) }
    # after_destroy -> { track_log(action: :deleted) }

    # Methods
    def track_log(action:)
      changes_to_log = action === :updated ? previous_changes.except('updated_at') : attributes.except('created_at', 'updated_at')
      logs.create(action: action, user_id: current_user_id, log_changes: changes_to_log) unless changes_to_log.empty?
    end
  end

  class_methods do
    # methods defined here are going to extend the class, not the instance of it
  end
end
