class Comment < ApplicationRecord
  # Associations
  belongs_to :ticket
  belongs_to :user

  # Validations
  validates :body, presence: true
end
