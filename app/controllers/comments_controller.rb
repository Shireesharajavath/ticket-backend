class CommentsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_ticket
  before_action :set_comment, only: [:update, :destroy]

  # GET /tickets/:ticket_id/comments
  def index
    comments = @ticket.comments.order(created_at: :asc)
    render json: comments.as_json(include: { user: { only: [:id, :username] } })
  end

  # POST /tickets/:ticket_id/comments
  def create
    return render json: { error: "Ticket is read-only" }, status: :forbidden if @ticket.read_only

    comment = @ticket.comments.build(user: current_user, body: params[:body], system_generated: false)
    if comment.save
      render json: {
        message: "Comment added successfully",
        comment: comment.as_json(include: { user: { only: [:id, :username] } })
      }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /tickets/:ticket_id/comments/:id
  def update
    return render json: { error: "Only author can edit" }, status: :forbidden unless @comment.user_id == current_user.id
    return render json: { error: "Ticket is read-only" }, status: :forbidden if @ticket.read_only

    if @comment.update(body: params[:body])
      render json: { message: "Comment updated", comment: @comment }, status: :ok
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/:ticket_id/comments/:id
  def destroy
    return render json: { error: "Only author can delete" }, status: :forbidden unless @comment.user_id == current_user.id
    @comment.destroy
    render json: { message: "Comment deleted successfully" }, status: :ok
  end

  private

  def set_ticket
    @ticket = Ticket.find_by(id: params[:ticket_id])
    render(json: { error: "Ticket not found" }, status: :not_found) and return unless @ticket
  end

  def set_comment
    @comment = @ticket.comments.find_by(id: params[:id]) if @ticket
    render(json: { error: "Comment not found" }, status: :not_found) and return unless @comment
  end
end
