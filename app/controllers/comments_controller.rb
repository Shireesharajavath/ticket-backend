class CommentsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_ticket
  before_action :set_comment, only: [:update, :destroy]

  # GET /tickets/:ticket_id/comments
  def index
    comments = @ticket.comments
    render json: comments
  end

  # POST /tickets/:ticket_id/comments
  def create
    comment = @ticket.comments.new(comment_params)
    comment.user_id = @current_user.id

    if comment.save
      render json: comment, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tickets/:ticket_id/comments/:id
  def update
    if @comment.user_id != @current_user.id
      render json: { error: "Not authorized" }, status: :forbidden
      return
    end

    if @comment.update(comment_params)
      render json: @comment
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/:ticket_id/comments/:id
  def destroy
    if @comment.user_id != @current_user.id
      render json: { error: "Not authorized" }, status: :forbidden
      return
    end

    @comment.destroy
    render json: { message: "Comment deleted" }
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:ticket_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Ticket not found" }, status: :not_found
  end

  def set_comment
    @comment = @ticket.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Comment not found" }, status: :not_found
  end

  # Handles both standard nested JSON and flat JSON for comment creation
  def comment_params
    # Try to fetch nested `comment` first, fallback to flat params
    if params[:comment]
      params.require(:comment).permit(:body, :system_generated)
    else
      params.permit(:body, :system_generated)
    end
  end
end
