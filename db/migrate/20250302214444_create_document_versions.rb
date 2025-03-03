class CreateDocumentVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :document_versions do |t|
      t.references :room, null: false, foreign_key: true
      t.integer :version_number, default: 0

      t.timestamps
    end
  end
end
