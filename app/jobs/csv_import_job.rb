require 'csv'

class CsvImportJob
  include Sidekiq::Job

  def perform(data_source_id, import_history_id)
    Rails.logger.info "Starting CSV import job for data source: #{data_source_id}, import_history: #{import_history_id}"

    data_source = DataSource.find(data_source_id)
    import_history = ImportHistory.find(import_history_id)

    begin
      unless import_history.file.attached?
        raise "No file attached to import history"
      end

      file_path = ActiveStorage::Blob.service.path_for(import_history.file.key)

      Rails.logger.info "Processing file: #{file_path}"
      total_rows = 0
      processed_rows = 0
      error_rows = 0
      error_details = []

      CSV.foreach(file_path, headers: true) do |row|
        total_rows += 1
        Rails.logger.debug "Processing row #{total_rows}: #{row.to_h}"

        begin
          process_row(data_source, row)
          processed_rows += 1
        rescue StandardError => e
          error_rows += 1
          error_details << {
            row: total_rows,
            error: e.message,
            data: row.to_h
          }
          Rails.logger.error "Error processing row #{total_rows}: #{e.message}"
        end

        if (total_rows % 100).zero?
          update_progress(import_history, total_rows, processed_rows, error_rows)
        end
      end

      complete_import(import_history, total_rows, processed_rows, error_rows, error_details)

      Rails.logger.info "Import completed successfully"
    rescue StandardError => e
      Rails.logger.error "Import failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      import_history.update!(
        status: 'failed',
        error_details: [{
          error: e.message,
          backtrace: e.backtrace.first(5)
        }]
      )
    end
  end

  private

  def process_row(data_source, row)
    Rails.logger.info "Processing row: #{row.to_h}"
  end

  def update_progress(import_history, total, processed, errors)
    import_history.update!(
      total_rows: total,
      processed_rows: processed,
      error_rows: errors,
      status: 'processing'
    )
  end

  def complete_import(import_history, total, processed, errors, details)
    import_history.update!(
      status: errors.zero? ? 'completed' : 'completed_with_errors',
      total_rows: total,
      processed_rows: processed,
      error_rows: errors,
      error_details: details
    )
  end
end
