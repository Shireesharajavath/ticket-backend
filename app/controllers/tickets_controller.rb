class TicketsController < ApplicationController
  before_action :authenticate_request!
  before_action :set_ticket, only: [:show, :update]
  before_action :authorize_ticket_update, only: [:update]

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
    ticket = @current_user.created_tickets.new(ticket_params)
    ticket.status ||= "Pending"

    if ticket.save
      render json: { message: "Ticket created successfully", ticket: ticket }, status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tickets/:id
  def update
    if @ticket.update(ticket_params)
      render json: { message: "Ticket updated successfully", ticket: @ticket }
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
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

  # --- Shared Methods ---

  def set_ticket
    @ticket = Ticket.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Ticket not found" }, status: :not_found
  end

  def ticket_params
    params.require(:ticket).permit(:title, :description, :status, :priority, :assignee_id)
  end

  # --- 🚦 Business Rules Section ---
  def authorize_ticket_update
    # 🚫 Rule 5: Once Done → read-only
    if @ticket.status == "Done"
      render json: { error: "Ticket is read-only (Done)." }, status: :forbidden and return
    end

    # 🧩 Rule 1: Title/description → only creator
    if (params[:ticket][:title].present? || params[:ticket][:description].present?) &&
       @ticket.creator_id != @current_user.id
      render json: { error: "Only the creator can edit title/description." }, status: :forbidden and return
    end

    # 🧩 Rule 2: Status/assignee → only creator or current assignee
    if (params[:ticket][:status].present? || params[:ticket][:assignee_id].present?) &&
       ![@ticket.creator_id, @ticket.assignee_id].include?(@current_user.id)
      render json: { error: "Only the creator or assignee can change status/assignee." }, status: :forbidden and return
    end

    # ⚙️ Rule 3: When status changes to Ready → auto assign to creator
    if params[:ticket][:status] == "Ready"
      @ticket.assignee_id = @ticket.creator_id
    end
  end
end
