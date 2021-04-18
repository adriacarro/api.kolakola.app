class V1::LinesController < ApplicationController
  before_action :find_queue

  # POST /queues/{id}/yield
  def yield
    @queue.insert_at(@queue.position + params[:position].to_i)
    render json: @queue, status: :ok
  end

  # PUT /queues/{id}
  def update
    @queue.update!(queue_params)
    render json: @queue, status: :ok
  end

  # DELETE /users/{id}
  def destroy
    @queue.abandoned!
    head :no_content
  end

  private

  def find_queue
    @queue = current_user.lines.find_by(id: params[:id])
    authorize @queue
  end

  def queue_params
    params.require(:line).permit(:status)
  end
end
