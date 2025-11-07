class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body
      t.boolean :system_generated
      t.timestamps
    end
  end
end
