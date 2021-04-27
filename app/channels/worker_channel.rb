class WorkerChannel < ApplicationCable::Channel
  def subscribed
    @user = User.worker.find(params[:user])
    stream_for @user
  end

  def check
    @user.attending_lines.each{ |line| @user.broadcast(line: line) }
  end

  def start
    @user.stop_break!
  end

  def stop
    @user.start_break!
  end

  def ready(data)
    @user.attending_lines.pending.find_by(id: data['id']).serving!
  end

  def finish(data)
    @user.attending_lines.serving.find_by(id: data['id']).served!
  end

  def miss(data)
    @user.attending_lines.pending.find_by(id: data['id']).abandoned!
  end

  def unsubscribed
    @user.start_break!
  end
end
