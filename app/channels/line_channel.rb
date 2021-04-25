class LineChannel < ApplicationCable::Channel
  def subscribed
    @line = Line.find(params[:line])
    stream_for @line
  end

  def ready
    @line.pending!
  end

  def abandon
    @line.abandoned!
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
