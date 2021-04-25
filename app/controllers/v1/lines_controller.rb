class V1::LinesController < ApplicationController
  before_action :find_line

  # POST /lines/{id}/yield
  def yield
    @line.insert_at(@line.position + params[:position].to_i)
    render json: @line, status: :ok
  end

  # PUT /lines/{id}
  def update
    @line.send("#{params[:status]}!")
    render json: @line, status: :ok
  end

  # DELETE /users/{id}
  def destroy
    @line.abandoned!
    head :no_content
  end

  private

  def find_line
    @line = current_user.lines.find_by(id: params[:id])
    authorize @line
  end

  def line_params
    params.require(:line).permit(:status)
  end
end
