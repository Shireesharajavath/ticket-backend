class User < ApplicationRecord
  has_secure_password

  # Associations
  has_many :created_tickets, class_name: "Ticket", foreign_key: "creator_id", dependent: :destroy
  has_many :assigned_tickets, class_name: "Ticket", foreign_key: "assignee_id"
  has_many :comments, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }
end
