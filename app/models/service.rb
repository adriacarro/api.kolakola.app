class Service < ApplicationRecord
  extend Mobility

  # Relations
  belongs_to :place
  has_many :users, -> { order(first_name: :asc) }, dependent: :destroy
  has_many :lines, dependent: :nullify

  # Extensions
  translates :name

  # Scopes
  default_scope -> { i18n.order(name: :asc) }

  # Methods
  def free_worker
    users.active.where.not(id: lines.in_process.pluck(:worker_id)).shuffle.first&.id
  end

  def in_process
    lines.in_process.count
  end

  def workers
    users.active.count
  end

  def free_workers?
    workers > in_process
  end
end
