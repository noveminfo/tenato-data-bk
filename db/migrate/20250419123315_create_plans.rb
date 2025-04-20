class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.string :name, null: false
      t.json :features, null: false
      t.decimal :monthly_price, precision: 10, scale: 2, null: false
      t.integer :max_users
      t.integer :max_data_sources
      t.integer :max_storage_gb
      t.boolean :api_access_enabled, default: false

      t.timestamps
    end
  end
end
