class AddPlanDetailsToOrganizations < ActiveRecord::Migration[7.1]
  def change
    add_reference :organizations, :plan, foreign_key: true, null: true
    add_column :organizations, :subscription_status, :string, default: 'trial'
    add_column :organizations, :trial_ends_at, :datetime
    add_column :organizations, :settings, :json
    add_column :organizations, :usage_limits, :json
  end
end
