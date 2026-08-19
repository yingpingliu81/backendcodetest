require "spec_helper"
require "models/account"
require "repositories/account_repository"

RSpec.describe AccountRepository do
  subject(:repository) { described_class.new }

  let(:account_a) { Account.new(number: "1111234522226789", balance: BigDecimal("5000.00")) }
  let(:account_b) { Account.new(number: "2222123433331212", balance: BigDecimal("550.00")) }

  describe "#add" do
    it "stores the account" do
      expect { repository.add(account_a) }
        .to change { repository.find(account_a.number) }.from(nil).to(account_a)
    end

    it "raises DuplicateAccountError when adding a duplicate number" do
      duplicate = Account.new(number: account_a.number, balance: BigDecimal("1000.00"))
      repository.add(account_a)
      expect { repository.add(duplicate) }
        .to raise_error(described_class::DuplicateAccountError, /already exists/)
      expect(repository.find(account_a.number)).to eq(account_a)
    end
  end

  describe "#find" do
    before { repository.add(account_a) }

    it "returns the account for a known number" do
      expect(repository.find(account_a.number)).to eq(account_a)
    end

    it "returns nil for an unknown number" do
      expect(repository.find("9999999999999999")).to be_nil
    end
  end

  describe "#all" do
    it "returns all stored accounts" do
      repository.add(account_a)
      repository.add(account_b)
      expect(repository.all).to contain_exactly(account_a, account_b)
    end

    it "returns an empty array when no accounts are stored" do
      expect(repository.all).to eq([])
    end
  end
end