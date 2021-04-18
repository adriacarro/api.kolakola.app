class Line < ApplicationRecord
  # Relations
  belongs_to :service
  belongs_to :customer, class_name: "User", foreign_key: "customer_id"
  belongs_to :worker, class_name: "User", foreign_key: "worker_id"

  # Extensions
  acts_as_list scope: [:service_id, :status]

  # Attributes
  enum status: %i[waiting pending serving served abandoned]

  # Callbacks
  before_create :assign_unique_code

  # Scope
  default_scope -> { order(position: :asc) }

  # Methods
  def pending!
    return if pending?

    update_columns(status: :pending, queueing_time: Datetime.now.to_f - created_at.to_f)
    remove_from_list
    start_queue_handshake
  end

  def served!
    return if served?

    update_columns(status: :served, serving_time: Datetime.now.to_f - (created_at + queueing_time.seconds).to_f)
    call_to_next
  end

  def abandoned!
    return if abandoned?
    super

    position.blank? ? call_to_next : remove_from_list # If they weren't in the queue is because they were in handshake, otherwise, move the queue
  end

  private

  def assign_unique_code
    self.code = loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless Line.where(service_id: service_id).waiting.exists?(token: code)
    end
  end

  def start_queue_handshake
    # Notify customer that is his/her turn
  end

  def call_to_next
    next_to_be_served = service.lines.waiting.first&.pending!
  end
end
