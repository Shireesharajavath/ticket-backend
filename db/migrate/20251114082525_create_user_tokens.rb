class CreateUserTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :user_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token
      t.string :jti
      t.boolean :revoked
      t.datetime :expires_at

      t.timestamps
    end
  end
end
