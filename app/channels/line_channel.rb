class LineChannel < ApplicationCable::Channel
  def subscribed
    line = Line.find(params[:queue])
    stream_for line
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
