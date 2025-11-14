class Ticket < ApplicationRecord
  STATUSES = ["Pending", "In Progress", "Ready", "Done"].freeze
  PRIORITIES = ["Low", "Medium", "High"].freeze

  # === Associations ===
  belongs_to :creator, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :comments, dependent: :destroy

  # === Validations ===
  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }, allow_nil: true

  # === Callbacks ===
  before_update :handle_status_change

  private

  # === Business Rules in Model ===
  def handle_status_change
    # 1️⃣ Once the ticket is Done, prevent any further edits
    if status_was == "Done"
      errors.add(:base, "Cannot modify a completed (Done) ticket.")
      throw(:abort)
    end

    # 2️⃣ If status changes to Ready → assign to creator automatically
    if status_changed? && status == "Ready"
      self.assignee_id = creator_id
    end

    # 3️⃣ Enforce status flow: Pending → In Progress → Ready → Done
    if status_changed?
      current_index = STATUSES.index(status_was)
      new_index = STATUSES.index(status)

      if new_index < current_index
        errors.add(:status, "cannot move backward from #{status_was} to #{status}.")
        throw(:abort)
      end
    end
  end
end
