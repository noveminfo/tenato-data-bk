module Api
  module V1
    class DashboardController < ApplicationController
      def summary
        render json: {
          organization: organization_summary,
          data_sources: data_sources_summary,
          recent_imports: recent_imports_summary,
          import_stats: import_statistics
        }
      end

      private

      def organization_summary
        {
          name: current_organization.name,
          plan: current_organization.plan,
          total_users: current_organization.users.active.count,
          total_data_sources: current_organization.data_sources.count
        }
      end

      def data_sources_summary
        current_organization.data_sources.map do |source|
          {
            id: source.id,
            name: source.name,
            type: source.source_type,
            total_imports: source.import_histories.count,
            successful_imports: source.import_histories.where(status: 'completed').count,
            failed_imports: source.import_histories.where(status: 'failed').count,
            last_import: source.import_histories.order(created_at: :desc).first&.created_at
          }
        end
      end

      def recent_imports_summary
        current_organization.data_sources
          .joins(:import_histories)
          .select('data_sources.name, import_histories.*')
          .merge(ImportHistory.recent.limit(5))
          .map do |history|
            {
              data_source_name: history.name,
              file_name: history.file_name,
              status: history.status,
              processed_rows: history.processed_rows,
              error_rows: history.error_rows,
              created_at: history.created_at
            }
          end
      end

      def import_statistics
        histories = ImportHistory.joins(data_source: :organization)
          .where(data_sources: { organization_id: current_organization.id })

        {
          total_imports: histories.count,
          total_processed_rows: histories.sum(:processed_rows),
          total_error_rows: histories.sum(:error_rows),
          success_rate: calculate_success_rate(histories),
          status_breakdown: status_breakdown(histories),
          daily_import_counts: daily_import_counts(histories)
        }
      end

      def calculate_success_rate(histories)
        total = histories.count
        return 0 if total.zero?

        successful = histories.where(status: 'completed').count
        (successful.to_f / total * 100).round(2)
      end

      def status_breakdown(histories)
        histories.group(:status).count
      end

      def daily_import_counts(histories)
        histories.group_by_day(:created_at, last: 30)
          .count
          .transform_keys { |k| k.strftime('%Y-%m-%d') }
      end
    end
  end
end