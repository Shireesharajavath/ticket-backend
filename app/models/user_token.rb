class UserToken < ApplicationRecord
  belongs_to :user

  # Validations
  validates :token, presence: true, uniqueness: true

  # Scope to fetch only active tokens (not revoked)
  scope :active, -> { where(revoked: false) }
end
