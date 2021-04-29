class AbandonLineJob < ApplicationJob
  queue_as :default

  def perform(line)
    line.abandoned! if line.waiting?
  end
end
