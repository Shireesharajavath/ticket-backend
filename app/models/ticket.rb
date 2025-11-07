class Ticket < ApplicationRecord
  STATUSES = ["Pending", "In Progress", "Ready", "Done"].freeze
  PRIORITIES = ["Low", "Medium", "High"].freeze

  # Associations
  belongs_to :creator, class_name: "User"
  belongs_to :assignee, class_name: "User", optional: true
  has_many :comments, dependent: :destroy

  # Validations
  validates :title, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :priority, inclusion: { in: PRIORITIES }, allow_nil: true
end
