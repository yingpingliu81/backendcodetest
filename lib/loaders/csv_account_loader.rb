require "csv"
require "loaders/loader"
require "models/account"

class CsvAccountLoader
  include Loader

  def initialize(file_path)
    @file_path = file_path
  end

  # Lazily streams one row at a time — O(1) memory regardless of file size.
  def load
    CSV.foreach(@file_path).lazy.map do |row|
      Account.new(number: row[0], balance: row[1])
    end
  end
end