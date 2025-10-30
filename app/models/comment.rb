class Comment < ApplicationRecord
  belongs_to :ticket
  belongs_to :user

  # Marks system comments (e.g., "Status changed to Done")
  attribute :system_generated, :boolean, default: false

  validates :body, presence: true
end
