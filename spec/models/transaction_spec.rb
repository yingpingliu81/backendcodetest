require "spec_helper"
require "models/transaction"

RSpec.describe Transaction do
  let(:transaction) do
    described_class.new(
      from_account_number: "1111234522226789",
      to_account_number: "1212343433335665",
      amount: "500.00",
      row_number: 1
    )
  end

  describe "attributes" do
    it "stores the from account number" do
      expect(transaction.from_account_number).to eq("1111234522226789")
    end

    it "stores the to account number" do
      expect(transaction.to_account_number).to eq("1212343433335665")
    end

    it "stores the amount as a BigDecimal" do
      expect(transaction.amount).to eq(BigDecimal("500.00"))
      expect(transaction.amount).to be_a(BigDecimal)
    end

    it "coerces a Float amount to BigDecimal" do
      float_transaction = described_class.new(
        from_account_number: "1111234522226789",
        to_account_number: "1212343433335665",
        amount: 500.0,
        row_number: 2
      )
      expect(float_transaction.amount).to eq(BigDecimal("500.00"))
      expect(float_transaction.amount).to be_a(BigDecimal)
    end

    it "stores the row number" do
      expect(transaction.row_number).to eq(1)
    end
  end

  describe "immutability" do
    it "exposes no writers" do
      expect(transaction).not_to respond_to(:from_account_number=)
      expect(transaction).not_to respond_to(:to_account_number=)
      expect(transaction).not_to respond_to(:amount=)
      expect(transaction).not_to respond_to(:row_number=)
    end
  end
end