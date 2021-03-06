# frozen_string_literal: true

class User < ApplicationRecord
  include Loggable
  
  # ¬†Relations
  belongs_to :place, optional: true
  has_many :user_services, dependent: :destroy
  has_many :services, through: :user_services
  has_many :lines, class_name: "Line", foreign_key: "customer_id", dependent: :nullify
  has_many :attending_lines, class_name: "Line", foreign_key: "worker_id", dependent: :nullify
  has_many :user_logs, class_name: 'Log', dependent: :destroy
  has_many :ratings, dependent: :nullify

  # Validations
  validates :email, presence: true, uniqueness: { scope: :place, case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: -> { customer? }
  validates :password, presence: true, if: -> { new_record? }
  validates :password, length: { in: 8..60 }, if: -> { new_record? || !password.nil? }
  validates :password, format: { with: /(?=.*[a-zA-Z])((?=.*[0-9])|(?=.*([[:print:]][^[[:alnum:]]]))).{8,}/ }, if: -> { new_record? || !password.nil? }
  validates :password, confirmation: { case_sensitive: true }, if: -> { password_confirmation.present? }

  # ¬†Attributes
  enum role: %i[admin worker customer]
  enum notification_type: %i[undefined web_notification whatsapp telegram sms]

  LOCKED_TIME = 5
  MAX_FAILED_ATTEMPTS = 5
  RESET_PASSWORD_TIME = 20

  # Extensions
  has_secure_password
  has_secure_token :reset_password_token

  # Scopes
  scope :search, ->(q) { where('email ILIKE :q OR first_name ILIKE :q', q: "%#{q}%") }
  scope :active, -> { where(active: true) }
  scope :sent, -> { where(invite_accepted: false) }
  scope :accepted, -> { where(invite_accepted: true) }
  scope :with_failed_attempts, -> { where('failed_attempts > 0') }
  scope :to_clean, -> { where("(reset_password_token is not null) and reset_password_sent_at < '#{(Time.now + 10.minutes).strftime('%Y-%m-%d %H:%M:%S')}'") }

  # Callbacks
  before_create :set_cookie, if: -> { customer? }
  after_create :invite!
  before_validation :set_random_password, on: :create
  before_save :clean_fields, if: -> { password_confirmation.present? }

  # Methods
  def authenticate!(password)
    if invite_accepted
      authenticate(password) ? success : failed
    else
      errors.add(:base, :accept_invite)
    end

    raise ActiveRecord::RecordInvalid.new(self) if self.errors.any?
   end

  def reset_password!
    regenerate_reset_password_token
    update_columns(reset_password_sent_at: Time.now)
    AuthMailer.reset_password(self).deliver_later
  end

  def reset_password_expired?
    !Time.now.between?(reset_password_sent_at, reset_password_sent_at + RESET_PASSWORD_TIME.minutes)
  end

  def invite!(current_user_id: nil)
    raise Error::AuthorizationError.new(403, :forbidden, I18n.t('activerecord.errors.messages.invitation_already_accepted')) if invite_accepted
    update(invite_token: JsonWebToken.encode(ActiveModelSerializers::SerializableResource.new(self, adapter: :json, root: :user).serializable_hash, 1.year.from_now), invited_at: Time.now, invite_accepted: false, current_user_id: current_user_id)
    AuthMailer.invite(self).deliver_later
  end

  def logout!
    start_break! if worker?
    services.select{ |service| service.user_services.count == 1 }.map(&:inactive!) if worker?
    update(log_out_at: Time.now, current_user_id: id)
  end

  def invitation
    return 'accepted' if invite_accepted
    'sent'
  end

  def self.not_found
    user = User.new
    user.errors.add(:base, :email_or_password_incorrect)
    user
  end

  def name
    [first_name, last_name].compact.join(' ')
  end

  def start_break!
    update_columns(active: false)
    broadcast(line: nil)
    services.each(&:broadcast)
  end

  def stop_break!
    update_columns(active: true)
    broadcast(line: nil)
    services.each(&:active!)
    services.each(&:broadcast)
    call_to_next if attending_lines.in_process.none?
  end

  # 1st step of line handshake
  def call_to_next
    return unless active

    next_to_be_served = services.active.map{ |service| service.lines.waiting.first }.compact.shuffle.first
    return if next_to_be_served.nil? # No more attendees

    # Start line handshake
    next_to_be_served.start_handshake(worker: self)
  end

  def broadcast(line:)
    serializer = line.nil? ? ActiveModelSerializers::SerializableResource.new(self, serializer: TinyUserSerializer) : ActiveModelSerializers::SerializableResource.new(line)
    line.nil? ? UserChannel.broadcast_to(self, serializer.serializable_hash) : WorkerChannel.broadcast_to(self, serializer.serializable_hash)
  end

  private
    def locked?
      failed_attempts == MAX_FAILED_ATTEMPTS && !locked_at.blank? && Time.now.between?(locked_at, locked_at + LOCKED_TIME.minutes)
    end

    def success
      if locked?
        errors.add(:base, :account_locked)
      else
        increment!(:sign_in_count)
        update_columns(sign_in_at: Time.now, failed_attempts: 0, locked_at: nil)
      end
    end

    def failed
      increment!(:failed_attempts)
      if failed_attempts == MAX_FAILED_ATTEMPTS
        update_columns(locked_at: Time.now)
        errors.add(:base, :max_failed_attempts)
      else
        errors.add(:base, :email_or_password_incorrect)
      end
    end

    def set_random_password
      loop do
        self.password = SecureRandom.urlsafe_base64(32)
        break if self.password.match?(/(?=.*[a-zA-Z])((?=.*[0-9])|(?=.*([[:print:]][^[[:alnum:]]]))).{8,}/)
      end
    end

    def set_cookie
      self.cookie = loop do
        cookie = SecureRandom.alphanumeric(32).upcase
        break cookie unless User.customer.exists?(cookie: cookie)
      end
    end

    def clean_fields
      self.reset_password_token = nil
      self.reset_password_sent_at = nil
    end
end
