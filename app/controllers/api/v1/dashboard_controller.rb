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

      def charts
        render json: {
          import_trends: import_trends_chart,
          status_distribution: status_distribution_chart,
          hourly_activity: hourly_activity_chart,
          data_source_performance: data_source_performance_chart
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

      def import_trends_chart
        data = ImportHistory.joins(data_source: :organization)
          .where(data_sources: { organization_id: current_organization.id })
          .group_by_day(:created_at, last: 30)
          .count
          .transform_keys { |k| k.strftime('%Y-%m-%d') }

        ChartDataFormatter.format_time_series(
          data,
          label: 'Daily Imports',
          fill: true
        )
      end

      def status_distribution_chart
        data = ImportHistory.joins(data_source: :organization)
          .where(data_sources: { organization_id: current_organization.id })
          .group(:status)
          .count

        ChartDataFormatter.format_pie_chart(data)
      end

      def hourly_activity_chart
        data = ImportHistory.joins(data_source: :organization)
          .where(data_sources: { organization_id: current_organization.id })
          .group_by_hour_of_day(:created_at)
          .count
          .transform_keys { |k| "#{k}:00" }

        ChartDataFormatter.format_bar_chart(
          data,
          label: 'Hourly Import Activity'
        )
      end

      def data_source_performance_chart
        data = current_organization.data_sources.map do |source|
          {
            name: source.name,
            success_rate: source.success_rate,
            total_imports: source.import_histories.count,
            total_rows: source.import_histories.sum(:processed_rows)
          }
        end

        {
          labels: data.map { |d| d[:name] },
          datasets: [
            {
              label: 'Success Rate (%)',
              data: data.map { |d| d[:success_rate] },
              type: 'line',
              yAxisID: 'percentage'
            },
            {
              label: 'Total Imports',
              data: data.map { |d| d[:total_imports] },
              type: 'bar',
              yAxisID: 'count'
            }
          ],
          axes: {
            percentage: {
              min: 0,
              max: 100,
              position: 'left'
            },
            count: {
              min: 0,
              position: 'right'
            }
          }
        }
      end
    end
  end
end