class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.string :title
      t.text :description
      t.string :status
      t.integer :creator_id
      t.integer :assignee_id
      t.boolean :read_only

      t.timestamps
    end
  end
end
