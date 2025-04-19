class CreateImportHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :import_histories do |t|
      t.references :data_source, null: false, foreign_key: true
      t.string :file_name, null: false
      t.string :status, default: 'pending'
      t.integer :total_rows, default: 0
      t.integer :processed_rows, default: 0
      t.integer :error_rows, default: 0
      t.json :error_details

      t.timestamps
    end
  end
end
