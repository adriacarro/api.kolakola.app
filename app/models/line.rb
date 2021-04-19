class Line < ApplicationRecord
  # Relations
  belongs_to :service
  belongs_to :customer, class_name: "User", foreign_key: "customer_id"
  belongs_to :worker, class_name: "User", foreign_key: "worker_id"

  # Extensions
  acts_as_list scope: [:service_id, :status]

  # Attributes
  enum status: %i[waiting pending serving served abandoned]

  # Scope
  default_scope -> { order(position: :asc) }
  scope :in_process, -> { where("status = :pending OR status = :serving", pending: Line.statuses[:pending], serving: Line.statuses[:serving]) }

  # Callbacks
  before_create :assign_unique_code
  after_create :im_the_next_one?

  # Methods
  def pending!
    return if pending?
    super

    # TODO: Send websocket to worker
  end

  def serving!
    return if serving?

    update_columns(status: :serving, pending_time: Datetime.now.to_f - (created_at + queueing_time.seconds).to_f)

    # TODO: Send websocket to customer (Manuel is serving you!)
  end

  def served!
    return if served?

    update_columns(status: :served, serving_time: Datetime.now.to_f - (created_at + queueing_time.seconds + serving_time.seconds).to_f)
    worker.call_to_next(service: line.service)
  end

  def abandoned!
    return if abandoned?
    super

    position.blank? ? worker.call_to_next(service: line.service) : remove_from_list # If they weren't in the queue is because they were in handshake, otherwise, move the queue
  end

  private

  def assign_unique_code
    self.code = loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless Line.where(service_id: service_id).waiting.exists?(token: code)
    end
  end

  def im_the_next_one?
    return unless position == 1 && line.service.free_workers?
    line.service.free_worker&.call_to_next(service: line.service)
  end

  def start_handshake(worker:)
    remove_from_list
    update_columns(worker_id: worker.id, queueing_time: Datetime.now.to_f - created_at.to_f)
    
    # TODO: Send websocket to customer (Is your turn, are you there?)
    # TODO: Send websocket to worker (Waiting for next with code XXX)
  end
end
