require "spec_helper"
require "loaders/loader"
require "loaders/csv_transaction_loader"

RSpec.describe CsvTransactionLoader do
  let(:fixture_path) { File.expand_path("../fixtures/transactions.csv", __dir__) }
  subject(:loader) { described_class.new(fixture_path) }

  it_behaves_like "a loader"

  describe "#load" do
    it "returns a lazy Enumerator" do
      expect(loader.load).to be_a(Enumerator)
    end

    it "loads the correct number of rows" do
      expect(loader.load.count).to eq(3)
    end

    it "assigns 1-based row numbers in file order" do
      expect(loader.load.map { |row| row[:row_number] }).to eq([1, 2, 3])
    end

    it "loads each from/to account number" do
      rows = loader.load.to_a
      expect(rows.map { |r| r[:from_account_number] }).to contain_exactly(
        "1111234522226789",
        "3212343433335755",
        "3212343433335755"
      )
      expect(rows.map { |r| r[:to_account_number] }).to contain_exactly(
        "1212343433335665",
        "2222123433331212",
        "1111234522226789"
      )
    end

    it "loads the amount as a raw string from the CSV" do
      row = loader.load.first
      expect(row[:amount]).to eq("500.00")
    end

    it "raises Errno::ENOENT when the missing file is enumerated" do
      missing_path = File.expand_path("../fixtures/does_not_exist.csv", __dir__)
      expect { described_class.new(missing_path).load.to_a }
        .to raise_error(Errno::ENOENT)
    end
  end
end