class UserChannel < ApplicationCable::Channel
  def subscribed
    @user = User.worker.find(params[:user])
    stream_for @user
  end

  def unsubscribed
  end
end
