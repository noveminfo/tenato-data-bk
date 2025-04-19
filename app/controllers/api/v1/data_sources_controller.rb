require 'csv'

module Api
  module V1
    class DataSourcesController < ApplicationController
      before_action :set_data_source, only: [:show, :destroy, :upload, :import_status]

      def index
        @data_sources = current_organization.data_sources.active
        render json: @data_sources, include: [:import_histories]
      end

      def show
        render json: @data_source, include: [:import_histories]
      end

      def create
        @data_source = current_organization.data_sources.build(data_source_params)

        if @data_source.save
          render json: @data_source, status: :created
        else
          render json: { errors: @data_source.errors }, status: :unprocessable_entity
        end
      end

      def destroy
        @data_source.update!(status: 'inactive')
        head :no_content
      end

      def upload
        unless params[:file].present?
          return render json: { error: 'No file provided' }, status: :bad_request
        end

        file = params[:file]

        unless File.extname(file.original_filename).downcase == '.csv'
          return render json: { error: 'File must be a CSV' }, status: :bad_request
        end

        # インポート履歴を作成
        import_history = @data_source.import_histories.create!(
          file_name: file.original_filename,
          status: 'pending'
        )

        # ファイルを添付
        import_history.file.attach(file)

        # バックグラウンドジョブを開始
        CsvImportJob.perform_async(@data_source.id, import_history.id)

        render json: {
          message: 'File upload accepted. Processing started.',
          import_history_id: import_history.id
        }, status: :accepted
      rescue StandardError => e
        Rails.logger.error "Upload failed: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: e.message }, status: :internal_server_error
      end

      # インポート状況確認エンドポイント
      def import_status
        begin
          import_history = @data_source.import_histories.find(params[:import_history_id])
          render json: {
            id: import_history.id,
            status: import_history.status,
            total_rows: import_history.total_rows,
            processed_rows: import_history.processed_rows,
            error_rows: import_history.error_rows,
            created_at: import_history.created_at,
            updated_at: import_history.updated_at
          }
        rescue ActiveRecord::RecordNotFound
          render json: { error: 'Import history not found' }, status: :not_found
        end
      end

      private

      def set_data_source
        @data_source = current_organization.data_sources.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Data source not found' }, status: :not_found
      end

      def data_source_params
        params.require(:data_source).permit(:name, :source_type)
      end
    end
  end
end