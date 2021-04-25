class WorkerChannel < ApplicationCable::Channel
  def subscribed
    @user = User.worker.find(params[:user])
    stream_for @user
  end

  def break(data)
    @user.send("#{data[:action]}_break!")
  end

  def ready(data)
    puts "data > #{data}"
    puts "data class > #{data.class}"
    puts "data id > #{data[:id]}"
    @user.lines.pending.find_by(id: data[:id]).serving!
  end

  def finish(data)
    @user.lines.pending.find_by(id: data[:id]).served!
  end

  def miss(data)
    @user.lines.pending.find_by(id: data[:id]).abandoned!
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
