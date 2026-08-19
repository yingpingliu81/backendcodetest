require "csv"
require "loaders/loader"
require "models/transaction"

class CsvTransactionLoader
  include Loader

  def initialize(file_path)
    @file_path = file_path
  end

  # Lazily streams one row at a time — O(1) memory regardless of file size.
  def load
    Enumerator.new do |yielder|
      CSV.foreach(@file_path).with_index(1) do |row, row_number|
        yielder << Transaction.new(
          from_account_number: row[0],
          to_account_number: row[1],
          amount: row[2],
          row_number: row_number
        )
      end
    end
  end
end