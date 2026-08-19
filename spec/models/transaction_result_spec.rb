require "spec_helper"
require "models/transaction"
require "models/transaction_error"
require "models/transaction_result"

RSpec.describe TransactionResult do
  let(:transaction) do
    Transaction.new(
      from_account_number: "1111234522226789",
      to_account_number: "1212343433335665",
      amount: "500.00",
      row_number: 1
    )
  end

  describe "success results" do
    subject(:result) { described_class.new(transaction: transaction, success: true) }

    it "is successful" do
      expect(result.success?).to be(true)
    end

    it "has no error message" do
      expect(result.error_message).to be_nil
    end
  end

  describe "failure results" do
    subject(:result) do
      described_class.new(transaction: transaction, success: false, error_code: TransactionError::INSUFFICIENT_FUNDS)
    end

    it "is not successful" do
      expect(result.success?).to be(false)
    end

    it "delegates the error message to TransactionError" do
      expect(result.error_message).to eq("Insufficient funds")
    end
  end

  describe "#to_s" do
    it "includes the row number and outcome for a success" do
      result = described_class.new(transaction: transaction, success: true)
      expect(result.to_s).to include("row 1")
      expect(result.to_s).to include("success")
    end

    it "includes the row number, outcome, and message for a failure" do
      result = described_class.new(
        transaction: transaction,
        success: false,
        error_code: TransactionError::SENDER_NOT_FOUND
      )
      expect(result.to_s).to include("row 1")
      expect(result.to_s).to include("Sender account not found")
    end
  end
end