require "spec_helper"
require "loaders/loader"
require "loaders/csv_account_loader"
require "models/account"

RSpec.describe CsvAccountLoader do
  let(:fixture_path) { File.expand_path("../fixtures/account_balances.csv", __dir__) }
  subject(:loader) { described_class.new(fixture_path) }

  it_behaves_like "a loader"

  describe "#load" do
    it "returns a lazy Enumerator" do
      expect(loader.load).to be_a(Enumerator::Lazy)
    end

    it "loads the correct number of accounts" do
      expect(loader.load.count).to eq(3)
    end

    it "loads each account number" do
      expect(loader.load.map(&:number)).to contain_exactly(
        "1111234522226789",
        "2222123433331212",
        "1212343433335665"
      )
    end

    it "loads balances as BigDecimal" do
      account = loader.load.find { |a| a.number == "1111234522226789" }
      expect(account.balance).to eq(BigDecimal("5000.00"))
      expect(account.balance).to be_a(BigDecimal)
    end

    it "returns an empty Array when an empty CSV is enumerated" do
      empty_path = File.expand_path("../fixtures/empty_account_balances.csv", __dir__)
      expect(described_class.new(empty_path).load.to_a).to eq([])
    end

    it "raises Errno::ENOENT when the missing file is enumerated" do
      missing_path = File.expand_path("../fixtures/does_not_exist.csv", __dir__)
      expect { described_class.new(missing_path).load.to_a }
        .to raise_error(Errno::ENOENT)
    end
  end
end