module Api
  module V1
    class TenantController < ApplicationController
      before_action :require_admin

      def show
        render json: {
          organization: organization_details,
          usage_statistics: usage_statistics,
          subscription: subscription_details
        }
      end

      def update_settings
        begin
          if current_organization.update(organization_params)
            render json: {
              message: 'Settings updated successfully',
              settings: current_organization.settings
            }
          else
            render json: {
              error: 'Failed to update settings',
              details: current_organization.errors.full_messages
            }, status: :unprocessable_entity
          end
        rescue ArgumentError => e
          render json: {
            error: 'Invalid settings format',
            details: e.message
          }, status: :bad_request
        end
      end

      private

      def require_admin
        unless current_user.role == 'admin'
          render json: { error: 'Unauthorized' }, status: :forbidden
        end
      end

      def organization_params
        params.require(:organization).permit(
          settings: [:notification_email, :timezone, :date_format],
          usage_limits: [:daily_api_calls, :max_file_size_mb, :max_rows_per_import]
        )
      end

      def organization_details
        {
          id: current_organization.id,
          name: current_organization.name,
          plan: current_organization.plan&.name,
          settings: current_organization.settings,
          usage_limits: current_organization.usage_limits
        }
      end

      def usage_statistics
        {
          total_users: current_organization.users.count,
          total_data_sources: current_organization.data_sources.count,
          storage_usage_gb: current_organization.storage_usage,
          storage_limit_gb: current_organization.plan&.max_storage_gb,
          storage_usage_percentage: calculate_storage_percentage,
          active_users: current_organization.users.active.count
        }
      end

      def subscription_details
        {
          status: current_organization.subscription_status,
          trial_ends_at: current_organization.trial_ends_at,
          plan_limits: {
            max_users: current_organization.plan&.max_users,
            max_data_sources: current_organization.plan&.max_data_sources,
            max_storage_gb: current_organization.plan&.max_storage_gb
          }
        }
      end

      def calculate_storage_percentage
        return 0 if current_organization.plan&.max_storage_gb.nil?
        return 0 if current_organization.plan.max_storage_gb.zero?
        
        ((current_organization.storage_usage.to_f / current_organization.plan.max_storage_gb) * 100).round(1)
      end
    end
  end
end