class CreateTodos < ActiveRecord::Migration[5.0]
  def change
    create_table :todos do |t|
      t.belongs_to :user
      t.string :content, null: false
      t.timestamps
    end
  end
end
