class WorkerChannel < ApplicationCable::Channel
  def subscribed
    user = User.worker.find(params[:queue])
    stream_for user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
