class Line < ApplicationRecord
  # Relations
  belongs_to :service
  belongs_to :customer, class_name: "User", foreign_key: "customer_id"
  belongs_to :worker, class_name: "User", foreign_key: "worker_id", optional: true

  # Extensions
  acts_as_list scope: [:service_id, :status]

  # Attributes
  enum status: %i[waiting pending serving served abandoned]

  # Scope
  default_scope -> { order(position: :asc) }
  scope :active, -> { where("status = :waiting OR status = :pending OR status = :serving", waiting: Line.statuses[:waiting], pending: Line.statuses[:pending], serving: Line.statuses[:serving]) }
  scope :in_process, -> { where("status = :pending OR status = :serving", pending: Line.statuses[:pending], serving: Line.statuses[:serving]) }

  # Callbacks
  before_create :assign_unique_code, :notify_service_subscribers
  after_create :im_the_next_one?
  after_save :notify_line_subscribers, if: -> { saved_change_to_position? }

  # Methods
  def pending!
    return if pending?
    super

    # Send websocket to worker
    notify_worker_subscriber
  end

  def serving!
    return if serving?

    update_columns(status: :serving, pending_time: Datetime.now.to_f - (created_at + queueing_time.seconds).to_f)

    # Send websocket to customer (Manuel is serving you!)
    notify_line_subscribers
  end

  def served!
    return if served?

    update_columns(status: :served, serving_time: Datetime.now.to_f - (created_at + queueing_time.seconds + serving_time.seconds).to_f)
    worker.call_to_next(service: service)

    # Notifiy service subscribers that queue has been updated and customer that service has been finished
    notify_line_subscribers
    notify_service_subscribers
  end

  def abandoned!
    return if abandoned?
    super

    position.blank? ? worker.call_to_next(service: service) : remove_from_list # If they weren't in the queue is because they were in handshake, otherwise, move the queue

    notify_service_subscribers
  end

  private

  def assign_unique_code
    self.code = loop do
      code = SecureRandom.alphanumeric(6).upcase
      break code unless Line.where(service_id: service_id).waiting.exists?(code: code)
    end
  end

  def im_the_next_one?
    return unless position == 1 && service.free_workers?
    service.free_worker&.call_to_next(service: service)
  end

  def start_handshake(worker:)
    update_columns(worker_id: worker.id, queueing_time: Datetime.now.to_f - created_at.to_f)
    remove_from_list
  end

  def notify_line_subscribers
    LineChannel.broadcast_to self, ActiveModelSerializers::SerializableResource.new(self).serializable_hash
  end

  def notify_worker_subscriber
    WorkerChannel.broadcast_to worker, ActiveModelSerializers::SerializableResource.new(self).serializable_hash if worker.present?
  end

  def notify_service_subscribers
    ServiceChannel.broadcast_to service, ActiveModelSerializers::SerializableResource.new(service).serializable_hash
  end
end
