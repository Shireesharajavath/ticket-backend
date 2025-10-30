class Ticket < ApplicationRecord
  STATUSES = ["Pending", "In Progress", "Ready", "Done"].freeze

  belongs_to :creator, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }, allow_nil: true

  before_validation :set_default_status, on: :create
  before_update :apply_business_rules

  def set_default_status
    self.status ||= "Pending"
    self.read_only = false if read_only.nil?
  end

  private

  # business rule enforcement
  def apply_business_rules
    # once Done -> read_only true
    if status_changed? && status == "Done"
      self.read_only = true
      log_system_comment("Status changed to Done — ticket is now read-only")
    end

    # When set to Ready -> auto assign back to creator
    if status_changed? && status == "Ready"
      self.assignee = creator
      log_system_comment("Status changed to Ready — auto-assigned to creator")
    end
  end

  def log_system_comment(text)
    comments.build(user: creator, body: text, system_generated: true)
    # We'll save comment when ticket is saved because it's built on transaction
  end
end
