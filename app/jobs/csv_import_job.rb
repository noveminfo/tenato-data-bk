class CsvImportJob
  include Sidekiq::Job

  def perform(data_source_id, import_history_id)
    data_source = DataSource.find(data_source_id)
    import_history = ImportHistory.find(import_history_id)

    Rails.logger.info "Starting CSV import job for data source: #{data_source_id}"

    begin
      process_csv(data_source, import_history)
    rescue StandardError => e
      Rails.logger.error "Import job failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      handle_error(import_history, e)
    end
  end

  private

  def process_csv(data_source, import_history)
    total_rows = 0
    processed_rows = 0
    error_rows = 0
    error_details = []

    file_path = ActiveStorage::Blob.service.path_for(import_history.file.key)
    
    CSV.foreach(file_path, headers: true) do |row|
      total_rows += 1

      begin
        # ここでデータ処理のロジックを実装
        # 例: データを保存するなど
        process_row(data_source, row)
        processed_rows += 1
      rescue StandardError => e
        error_rows += 1
        error_details << {
          row: total_rows,
          error: e.message,
          data: row.to_h
        }
      end

      # 進捗状況の更新
      if (total_rows % 100).zero?
        update_progress(import_history, total_rows, processed_rows, error_rows)
      end
    end

    # 最終的な結果を保存
    complete_import(import_history, total_rows, processed_rows, error_rows, error_details)
  end

  def process_row(data_source, row)
    # ここに実際のデータ処理ロジックを実装
    # 例: データベースへの保存など
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

  def handle_error(import_history, error)
    import_history.update!(
      status: 'failed',
      error_details: [{ error: error.message }]
    )
  end
end
