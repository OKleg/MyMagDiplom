class CreateRooms < ActiveRecord::Migration[7.1]
  def change
    create_table :rooms do |t|
      t.string :name
      t.boolean :is_private, default: false

      t.text :content, null: false, default: ""
      t.integer :version, null: false, default: 0

      t.timestamps
    end
  end
end
