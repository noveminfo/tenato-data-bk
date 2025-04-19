require 'csv'

module Api
  module V1
    class DataSourcesController < ApplicationController
      before_action :set_data_source, only: [:show, :destroy, :upload]

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
        begin
          # ファイルの内容をチェック
          CSV.parse(file.read.force_encoding('UTF-8'), headers: true)
          file.rewind  # ファイルポインタを先頭に戻す
        rescue CSV::MalformedCSVError => e
          return render json: { error: 'Invalid CSV format' }, status: :bad_request
        end

        import_service = CsvImportService.new(@data_source, file)
        import_history = import_service.import

        render json: import_history
      rescue StandardError => e
        Rails.logger.error "CSV Upload Error: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: e.message }, status: :internal_server_error
      end

      private

      def set_data_source
        @data_source = current_organization.data_sources.find(params[:id])
      end

      def data_source_params
        params.require(:data_source).permit(:name, :source_type)
      end
    end
  end
end