# frozen_string_literal: true

class AuthMailer < ApplicationMailer
  def invite(user)
    @user = user
    mail(to: @user.email, subject: t("app.auth_mailer.invite.subject"))
  end

  def welcome(user)
    @user = user
    mail(to: @user.email, subject: t("app.auth_mailer.welcome.subject.#{user.role}"))
  end

  def reset_password(user)
    @user = user
    mail(to: @user.email, subject: t("app.auth_mailer.reset_password.subject"))
  end
end
