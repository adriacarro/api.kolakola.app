class WorkerChannel < ApplicationCable::Channel
  def subscribed
    @user = User.worker.find(params[:user])
    stream_for @user
  end

  def check
    @user.attending_lines.active.each{ |line| @user.broadcast(line: line) }
  end

  def start
    @user.stop_break!
  end

  def stop
    @user.start_break!
  end

  def ready
    @user.attending_lines.pending.first&.serving!
  end

  def finish
    @user.attending_lines.serving.first&.served!
  end

  def miss
    @user.attending_lines.pending.first&.abandoned!
  end

  def logout
    @user.logout!
  end

  def unsubscribed
  end
end
