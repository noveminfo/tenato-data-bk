require 'csv'

class CsvImportService
  def initialize(data_source, file)
    @data_source = data_source
    @file = file
    @organization = data_source.organization
    Rails.logger.info "Initializing CSV import for file: #{@file.original_filename}"
  end

  def import
    Rails.logger.info "Starting import process"
    import_history = create_import_history

    begin
      process_csv(import_history)
    rescue StandardError => e
      Rails.logger.error "Import failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      handle_error(import_history, e)
    end

    Rails.logger.info "Import completed with status: #{import_history.status}"
    import_history
  end

  private

  def create_import_history
    @data_source.import_histories.create!(
      file_name: @file.original_filename,
      status: 'processing'
    )
  end

  def process_csv(import_history)
    total_rows = 0
    processed_rows = 0
    error_rows = 0
    error_details = []

    Rails.logger.info "Processing CSV file"

    CSV.foreach(@file.path, headers: true) do |row|
      total_rows += 1
      Rails.logger.debug "Processing row #{total_rows}: #{row.to_h}"

      begin
        # ここで実際のデータ処理を行う
        # 例: データを保存するなど
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
    end

    update_import_history(
      import_history,
      total_rows,
      processed_rows,
      error_rows,
      error_details
    )
  end

  def update_import_history(import_history, total, processed, errors, details)
    import_history.update!(
      status: errors.zero? ? 'completed' : 'completed_with_errors',
      total_rows: total,
      processed_rows: processed,
      error_rows: errors,
      error_details: details
    )
  end

  def handle_error(import_history, error)
    import_history.update!(
      status: 'failed',
      error_details: [{ error: error.message }]
    )
    Rails.logger.error "CSV import failed: #{error.message}"
  end
end
