class AddDefaultToRevoked < ActiveRecord::Migration[7.0]
  def change
    change_column_default :user_tokens, :revoked, false
  end
end
