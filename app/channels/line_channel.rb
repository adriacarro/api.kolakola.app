class LineChannel < ApplicationCable::Channel
  def subscribed
    @line = Line.find(params[:line])
    stream_for @line
  end

  def check
    @line.broadcast
  end

  def ready
    @line.pending!
  end

  def abandon
    @line.abandoned!
  end

  def yield(data)
    @line.insert_at(@line.position + data['position'].to_i)
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
