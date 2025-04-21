class ImportHistorySerializer < ActiveModel::Serializer
  attributes :id, :file_name, :status, :total_rows, :processed_rows, 
             :error_rows, :error_details, :created_at, :updated_at

  belongs_to :data_source
end
