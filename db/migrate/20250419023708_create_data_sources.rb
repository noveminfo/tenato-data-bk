class CreateDataSources < ActiveRecord::Migration[7.1]
  def change
    create_table :data_sources do |t|
      t.string :name, null: false
      t.references :organization, null: false, foreign_key: true
      t.string :source_type, null: false
      t.string :status, default: 'active'

      t.timestamps
    end
  end
end
