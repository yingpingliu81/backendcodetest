require "spec_helper"
require "loaders/loader"
require "loaders/csv_transaction_loader"
require "models/transaction"

RSpec.describe CsvTransactionLoader do
  let(:fixture_path) { File.expand_path("../fixtures/transactions.csv", __dir__) }
  subject(:loader) { described_class.new(fixture_path) }

  it_behaves_like "a loader"

  describe "#load" do
    it "returns a lazy Enumerator" do
      expect(loader.load).to be_a(Enumerator)
    end

    it "loads the correct number of transactions" do
      expect(loader.load.count).to eq(3)
    end

    it "assigns 1-based row numbers in file order" do
      expect(loader.load.map(&:row_number)).to eq([1, 2, 3])
    end

    it "loads each from/to account number" do
      transactions = loader.load
      expect(transactions.map(&:from_account_number)).to contain_exactly(
        "1111234522226789",
        "3212343433335755",
        "3212343433335755"
      )
      expect(transactions.map(&:to_account_number)).to contain_exactly(
        "1212343433335665",
        "2222123433331212",
        "1111234522226789"
      )
    end

    it "loads amounts as BigDecimal" do
      transaction = loader.load.first
      expect(transaction.amount).to eq(BigDecimal("500.00"))
      expect(transaction.amount).to be_a(BigDecimal)
    end

    it "raises Errno::ENOENT when the missing file is enumerated" do
      missing_path = File.expand_path("../fixtures/does_not_exist.csv", __dir__)
      expect { described_class.new(missing_path).load.to_a }
        .to raise_error(Errno::ENOENT)
    end
  end
end