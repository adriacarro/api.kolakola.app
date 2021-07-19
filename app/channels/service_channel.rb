class ServiceChannel < ApplicationCable::Channel
  def subscribed
    @service = Service.find(params[:service])
    stream_for @service
  end

  def active
    @service.active!
  end

  def inactive
    @service.inactive!
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
