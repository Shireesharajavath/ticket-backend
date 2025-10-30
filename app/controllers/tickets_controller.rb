class TicketsController < ApplicationController
  before_action :authenticate_request!, except: [:index, :show]
  before_action :set_ticket, only: [:show, :update, :destroy]

  # ===========================
  # GET /tickets
  # ===========================
  def index
    scope = Ticket.all.includes(:creator, :assignee)
    scope = scope.where(creator_id: params[:creator_id]) if params[:creator_id].present?
    scope = scope.where(assignee_id: params[:assignee_id]) if params[:assignee_id].present?
    scope = scope.where(status: params[:status]) if params[:status].present?

    if params[:q].present?
      q = "%#{params[:q]}%"
      scope = scope.where("title ILIKE ? OR id::text ILIKE ?", q, q)
    end

    render json: scope.order(updated_at: :desc).as_json(
      include: {
        creator: { only: [:id, :username] },
        assignee: { only: [:id, :username] }
      }
    )
  end

  # ===========================
  # POST /tickets
  # ===========================
  def create
    ticket = Ticket.new(ticket_params)
    ticket.creator = current_user

    if ticket.save
      render json: ticket, status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ===========================
  # GET /tickets/:id
  # ===========================
  def show
    render json: @ticket.as_json(
      include: {
        comments: { include: { user: { only: [:id, :username] } } },
        creator: { only: [:id, :username] },
        assignee: { only: [:id, :username] }
      }
    )
  end

  # ===========================
  # PUT/PATCH /tickets/:id
  # ===========================
  def update
    return render json: { error: "Ticket is read-only" }, status: :forbidden if @ticket.read_only

    if editing_title_or_description?
      unless current_user.id == @ticket.creator_id
        return render json: { error: "Only creator can edit title/description" }, status: :forbidden
      end
    end

    if changing_status_or_assignee?
      unless [@ticket.creator_id, @ticket.assignee_id].compact.include?(current_user.id)
        return render json: { error: "Only creator or assignee can change status/assignee" }, status: :forbidden
      end
    end

    old_values = {
      title: @ticket.title,
      description: @ticket.description,
      status: @ticket.status,
      assignee_id: @ticket.assignee_id
    }

    if @ticket.update(ticket_params)
      handle_status_transitions(old_values, @ticket)
      log_change_comments(old_values, @ticket)
      render json: @ticket, status: :ok
    else
      render json: { errors: @ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # ===========================
  # DELETE /tickets/:id
  # ===========================
  def destroy
    if current_user.id == @ticket.creator_id
      @ticket.destroy
      render json: { message: "Ticket deleted successfully" }, status: :ok
    else
      render json: { error: "Only creator can delete this ticket" }, status: :forbidden
    end
  end

  # ===========================
  # GET /my/created
  # ===========================
  def created_by_me
    tickets = Ticket.where(creator_id: current_user.id)
    render json: tickets.as_json(include: { assignee: { only: [:id, :username] } })
  end

  # ===========================
  # GET /my/assigned
  # ===========================
  def assigned_to_me
    tickets = Ticket.where(assignee_id: current_user.id)
    render json: tickets.as_json(include: { creator: { only: [:id, :username] } })
  end

  private

  def set_ticket
    @ticket = Ticket.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Ticket not found" }, status: :not_found
  end

  def ticket_params
    params.permit(:title, :description, :status, :assignee_id)
  end

  def editing_title_or_description?
    params[:title].present? || params[:description].present?
  end

  def changing_status_or_assignee?
    params[:status].present? || params[:assignee_id].present?
  end

  def handle_status_transitions(old, ticket)
    if old[:status] != ticket.status
      case ticket.status.downcase
      when "ready"
        ticket.update(assignee_id: ticket.creator_id)
      when "done"
        ticket.update(read_only: true)
      end
    end
  end

  def log_change_comments(old, ticket)
    if old[:title] != ticket.title
      ticket.comments.create!(user: current_user, body: "Title changed from '#{old[:title]}' to '#{ticket.title}'", system_generated: true)
    end
    if old[:description] != ticket.description
      ticket.comments.create!(user: current_user, body: "Description changed", system_generated: true)
    end
    if old[:status] != ticket.status
      ticket.comments.create!(user: current_user, body: "Status changed from '#{old[:status]}' to '#{ticket.status}'", system_generated: true)
    end
    if old[:assignee_id] != ticket.assignee_id
      old_name = User.find_by(id: old[:assignee_id])&.username || "Unassigned"
      new_name = User.find_by(id: ticket.assignee_id)&.username || "Unassigned"
      ticket.comments.create!(user: current_user, body: "Assignee changed from '#{old_name}' to '#{new_name}'", system_generated: true)
    end
  end
end
