class CommentsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_ticket
  before_action :set_comment, only: [:update, :destroy]
  before_action :authorize_comment_action, only: [:create, :update, :destroy]

  # GET /tickets/:ticket_id/comments
  def index
    comments = @ticket.comments.includes(:user)
    render json: comments.to_json(include: :user)
  end

  # POST /tickets/:ticket_id/comments
  def create
    comment = @ticket.comments.new(comment_params)
    comment.user_id = @current_user.id  # track who created it

    if comment.save
      render json: { message: "Comment added successfully", comment: comment }, status: :created
    else
      render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tickets/:ticket_id/comments/:id
  def update
    # Only comment owner can update (checked in authorize_comment_action)
    if @comment.update(comment_params)
      render json: { message: "Comment updated successfully", comment: @comment }, status: :ok
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /tickets/:ticket_id/comments/:id
  def destroy
    # Only comment owner can delete (checked in authorize_comment_action)
    @comment.destroy
    render json: { message: "Comment deleted successfully" }, status: :ok
  end

  private

  # --- Helper methods ---
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

  def comment_params
    if params[:comment]
      params.require(:comment).permit(:body, :system_generated)
    else
      params.permit(:body, :system_generated)
    end
  end

  # --- 🚦 Business Rules Section ---
  def authorize_comment_action
    # Rule 3: If ticket is Done → no edits, adds, or deletes
    if @ticket.status == "Done"
      render json: { error: "Cannot modify comments for a completed (Done) ticket." }, status: :forbidden and return
    end

    # Rule 4: System-generated comments → not editable/deletable
    if @comment&.system_generated? && (action_name == "update" || action_name == "destroy")
      render json: { error: "System-generated comments cannot be modified or deleted." }, status: :forbidden and return
    end

    # Rule 2: Only comment owner can update/delete
    if ["update", "destroy"].include?(action_name) && @comment.user_id != @current_user.id
      render json: { error: "You can only edit or delete your own comments." }, status: :forbidden and return
    end
  end
end
