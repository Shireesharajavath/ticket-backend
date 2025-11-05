# app/models/ticket.rb
class Ticket < ApplicationRecord
  STATUSES = ["Pending", "In Progress", "Ready", "Done"].freeze

  belongs_to :creator, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }, allow_nil: true

  before_validation :set_default_status, on: :create
  before_update :apply_business_rules

  # ------------------------------
  # 🔍 SEARCH METHOD (for Retool)
  # ------------------------------
  def self.search_any(term)
    # If no term is provided, return all tickets
    return all if term.blank?

    t = term.strip
    numeric = t.match?(/\A\d+\z/) # true if purely a number

    # conditions array to build dynamic SQL
    conditions = []
    params = {}

    # Text-based search (case-insensitive for MySQL)
    conditions << "LOWER(title) LIKE :q"
    conditions << "LOWER(description) LIKE :q"
    conditions << "LOWER(status) LIKE :q"
    params[:q] = "%#{t.downcase}%"

    # If numeric, also match by IDs
    if numeric
      conditions << "id = :num"
      conditions << "creator_id = :num"
      conditions << "assignee_id = :num"
      params[:num] = t.to_i
    end

    where(conditions.join(" OR "), params)
  end

  # ------------------------------
  # Default status setup
  # ------------------------------
  def set_default_status
    self.status ||= "Pending"
    self.read_only = false if read_only.nil?
  end

  private

  # ------------------------------
  # Business rules on update
  # ------------------------------
  def apply_business_rules
    # When status becomes Done → ticket locked (read_only true)
    if status_changed? && status == "Done"
      self.read_only = true
      log_system_comment("Status changed to Done — ticket is now read-only")
    end

    # When status becomes Ready → auto-assign back to creator
    if status_changed? && status == "Ready"
      self.assignee = creator
      log_system_comment("Status changed to Ready — auto-assigned to creator")
    end
  end

  def log_system_comment(text)
    comments.build(user: creator, body: text, system_generated: true)
    # Comment will be saved automatically along with the ticket
  end
end
