class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.string :title , null: false, foreign_key: true
      t.text :description, null: false , foreign_key: true
      t.string :status , null: false, foreign_key: true
      t.string :priority , null: false, foreign_key: true
      t.integer :creator_id , null: false, foreign_key: true
      t.integer :assignee_id , foreign_key: true
      t.timestamps
    end
  end
end
