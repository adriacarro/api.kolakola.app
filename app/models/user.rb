# frozen_string_literal: true

class User < ApplicationRecord
  #  Relations
  belongs_to :place, optional: true
  belongs_to :service, optional: true

  # Validations
  validates :email, presence: true, uniqueness: { scope: :place, case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, if: -> { new_record? }
  validates :password, length: { in: 8..60 }, if: -> { new_record? || !password.nil? }
  validates :password, format: { with: /(?=.*[a-zA-Z])((?=.*[0-9])|(?=.*([[:print:]][^[[:alnum:]]]))).{8,}/ }, if: -> { new_record? || !password.nil? }
  validates :password, confirmation: { case_sensitive: true }, if: -> { password_confirmation.present? }

  #  Attributes
  enum role: %i[admin worker customer]
  enum notification_type: %i[none web_notification whatsapp telegram sms]

  LOCKED_TIME = 5
  MAX_FAILED_ATTEMPTS = 5
  RESET_PASSWORD_TIME = 20

  # Extensions
  has_secure_password
  has_secure_token :reset_password_token

  # Scopes
  scope :search, ->(q) { where('email ILIKE :q OR first_name ILIKE :q', q: "%#{q}%") }
  scope :sent, -> { where(invite_accepted: false) }
  scope :accepted, -> { where(invite_accepted: true) }
  scope :with_failed_attempts, -> { where('failed_attempts > 0') }
  scope :to_clean, -> { where("(reset_password_token is not null) and reset_password_sent_at < '#{(Time.now + 10.minutes).strftime('%Y-%m-%d %H:%M:%S')}'") }

  # Callbacks
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
  end

  def finish_break!
    update_columns(active: true)
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

    def clean_fields
      self.reset_password_token = nil
      self.reset_password_sent_at = nil
    end
end
