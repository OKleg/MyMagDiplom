class CreateOperations < ActiveRecord::Migration[7.1]
  def change
    create_table :operations do |t|
      t.references :document_version, null: false, foreign_key: true
      t.string :type, null: false
      t.text :text, null: false
      t.integer :position, null: false
      t.integer :version, null: false, default: 0

      t.timestamps
    end
    # add_index :operations, [:room_id, :version], unique: true

  end
end
