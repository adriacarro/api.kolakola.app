# frozen_string_literal: true

class Line < ApplicationRecord
  include Loggable

  # Relations
  belongs_to :service
  belongs_to :customer, class_name: "User", foreign_key: "customer_id", optional: true
  belongs_to :worker, class_name: "User", foreign_key: "worker_id", optional: true

  # Extensions
  acts_as_list scope: :service

  # Attributes
  enum status: %i[waiting pending serving served abandoned]

  # Scope
  default_scope -> { order(position: :asc) }
  scope :active, -> { where("status = :waiting OR status = :pending OR status = :serving", waiting: Line.statuses[:waiting], pending: Line.statuses[:pending], serving: Line.statuses[:serving]) }
  scope :in_process, -> { where("(status = :waiting AND worker_id IS NOT NULL) OR status = :pending OR status = :serving", waiting: Line.statuses[:waiting], pending: Line.statuses[:pending], serving: Line.statuses[:serving]) }

  # Callbacks
  before_create :assign_unique_code, :notify_service_subscribers
  after_create :im_the_next_one?
  after_save :broadcast, if: -> { saved_change_to_position? }

  # Methods
  def pending!
    return if pending?
    update(status: :pending, current_user_id: customer.id)

    # Send websocket to worker and customer
    worker.broadcast(line: self)
    broadcast
  end

  def serving!
    return if serving?

    update(status: :serving, pending_time: DateTime.now.to_f - (created_at + queueing_time.seconds).to_f, current_user_id: worker.id)

    # Send websocket to customer (Manuel is serving you!) and worker
    broadcast
    worker.broadcast(line: self)
  end

  def served!
    return if served?

    update(status: :served, serving_time: DateTime.now.to_f - (created_at + queueing_time.seconds + serving_time.seconds).to_f, current_user_id: worker.id)

    # Notifiy service subscribers that line has been updated and customer that service has been finished
    broadcast
    worker.broadcast(line: self)
    service.broadcast

    # Go to next (if there are)
    worker.call_to_next
  end

  def abandoned!
    return if abandoned?
    update(status: :abandoned, current_user_id: customer.id)

    # Notify service that queue has been modified and also customer and worker (if exists) that queue is no longer valid
    service.broadcast
    broadcast
    worker&.broadcast(line: self)

    position.blank? ? worker.call_to_next : remove_from_list # If they weren't in the line is because they were in handshake, otherwise, move the line
  end

  def start_handshake(worker:)
    update_columns(worker_id: worker.id, queueing_time: DateTime.now.to_f - created_at.to_f)
    remove_from_list
    # Give 20 seconds and if status is stil waiting > abandoned
    AbandonLineJob.set(wait: 22.seconds).perform_later(self)
  end

  def broadcast
    LineChannel.broadcast_to self, ActiveModelSerializers::SerializableResource.new(self).serializable_hash
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
    service.free_worker&.call_to_next
  end

  def notify_service_subscribers
    service.broadcast
  end
end
