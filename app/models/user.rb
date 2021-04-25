# frozen_string_literal: true

class User < ApplicationRecord
  #  Relations
  belongs_to :place, optional: true
  belongs_to :service, optional: true
  has_many :lines, class_name: "Line", foreign_key: "customer_id"

  # Validations
  validates :email, presence: true, uniqueness: { scope: :place, case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: -> { customer? }
  validates :password, presence: true, if: -> { new_record? }
  validates :password, length: { in: 8..60 }, if: -> { new_record? || !password.nil? }
  validates :password, format: { with: /(?=.*[a-zA-Z])((?=.*[0-9])|(?=.*([[:print:]][^[[:alnum:]]]))).{8,}/ }, if: -> { new_record? || !password.nil? }
  validates :password, confirmation: { case_sensitive: true }, if: -> { password_confirmation.present? }

  #  Attributes
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

  def invite!
    raise Error::AuthorizationError.new(403, :forbidden, I18n.t('activerecord.errors.messages.invitation_already_accepted')) if invite_accepted
    update(invite_token: JsonWebToken.encode(invite_json, 1.year.from_now), invited_at: Time.now, invite_accepted: false)
    AuthMailer.invite(self).deliver_later
  end

  def invite_json
    { user: { role: role } }
  end

  def login_json
    main_json = { id: id, first_name: first_name, last_name: last_name, email: email }
    main_json.merge!(role: role, place: place&.id) unless customer?
    main_json.merge!(cookie: cookie, lines: ActiveModelSerializers::SerializableResource.new(lines.active).serializable_hash) if customer?
    main_json
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
    services.each(&:broadcast)
  end

  def stop_break!
    update_columns(active: true)
    services.each(&:broadcast)
  end

  # 1st step of line handshake
  def call_to_next(service:)
    # Do nothing if not a worker or not attending this service
    return unless worker? && services.exists?(id: service.id)

    next_to_be_served = service.lines.waiting.first
    return if next_to_be_served.nil? # No more attendees

    # Start line handshake
    next_to_be_served.start_handshake(worker: self)
  end

  def broadcast(line:)
    WorkerChannel.broadcast_to self, ActiveModelSerializers::SerializableResource.new(line).serializable_hash
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
