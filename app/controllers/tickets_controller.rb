class TicketsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_ticket, only: [:show, :update]

  # GET /tickets
  # Optional filtering: /tickets?status=Done&priority=High
  def index
    tickets = Ticket.all.includes(:creator, :assignee, :comments)
    tickets = tickets.where(status: params[:status]) if params[:status].present?
    tickets = tickets.where(priority: params[:priority]) if params[:priority].present?
    tickets = tickets.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?

    render json: tickets.to_json(include: [:creator, :assignee, :comments])
  end

  # GET /tickets/:id
  def show
    render json: @ticket.to_json(include: [:creator, :assignee, :comments])
  end

  # POST /tickets
  def create
    ticket = Ticket.new(ticket_params)
    ticket.creator_id = @current_user.id
    ticket.status ||= "Pending"

    if ticket.save
      render json: { message: "Ticket created successfully", ticket: ticket }, status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tickets/:id
  def update
    # Only creator or assignee can update
    if @ticket.creator_id == @current_user.id || @ticket.assignee_id == @current_user.id
      if @ticket.update(ticket_params)
        render json: { message: "Ticket updated successfully", ticket: @ticket }
      else
        render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: "Not authorized to update this ticket" }, status: :forbidden
    end
  end

  # GET /my/created
  def created_by_me
    tickets = Ticket.where(creator_id: @current_user.id).includes(:creator, :assignee, :comments)
    render json: tickets.to_json(include: [:creator, :assignee, :comments])
  end

  # GET /my/assigned
  def assigned_to_me
    tickets = Ticket.where(assignee_id: @current_user.id).includes(:creator, :assignee, :comments)
    render json: tickets.to_json(include: [:creator, :assignee, :comments])
  end

  # GET /tickets/search?query=...
  def search
    query = params[:query]
    if query.present?
      tickets = Ticket.includes(:creator, :assignee, :comments).where(
        "LOWER(title) LIKE :q OR LOWER(description) LIKE :q OR LOWER(status) LIKE :q OR LOWER(priority) LIKE :q",
        q: "%#{query.downcase}%"
      )
      render json: tickets.to_json(include: [:creator, :assignee, :comments])
    else
      render json: { error: "Please provide a search query" }, status: :bad_request
    end
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Ticket not found" }, status: :not_found
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :status, :priority, :assignee_id,:creator_id)
  end
end
