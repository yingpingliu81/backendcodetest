require "spec_helper"
require "models/transaction"
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

  # ── Error code registry ──────────────────────────────────────────────────────

  CODES = [
    TransactionResult::SENDER_NOT_FOUND,
    TransactionResult::RECEIVER_NOT_FOUND,
    TransactionResult::SELF_TRANSFER,
    TransactionResult::INVALID_AMOUNT,
    TransactionResult::INSUFFICIENT_FUNDS
  ].freeze

  EXPECTED_MESSAGES = {
    TransactionResult::SENDER_NOT_FOUND   => "Sender account not found",
    TransactionResult::RECEIVER_NOT_FOUND => "Receiver account not found",
    TransactionResult::SELF_TRANSFER      => "Cannot transfer to the same account",
    TransactionResult::INVALID_AMOUNT     => "Amount must be a positive number",
    TransactionResult::INSUFFICIENT_FUNDS => "Insufficient funds"
  }.freeze

  describe "error codes" do
    CODES.each do |code|
      it "defines #{code} as a Symbol" do
        expect(code).to be_a(Symbol)
      end
    end

    it "defines unique error codes" do
      expect(CODES.uniq.size).to eq(CODES.size)
    end
  end

  describe ".message_for" do
    EXPECTED_MESSAGES.each do |code, message|
      it "returns #{message.inspect} for #{code}" do
        expect(described_class.message_for(code)).to eq(message)
      end
    end

    it "returns a fallback message for an unknown code" do
      expect(described_class.message_for(:bogus)).to eq("Unknown error")
    end
  end

  # ── Instance behaviour ───────────────────────────────────────────────────────

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
      described_class.new(transaction: transaction, success: false, error_code: TransactionResult::INSUFFICIENT_FUNDS)
    end

    it "is not successful" do
      expect(result.success?).to be(false)
    end

    it "resolves the error message from its own registry" do
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
        error_code: TransactionResult::SENDER_NOT_FOUND
      )
      expect(result.to_s).to include("row 1")
      expect(result.to_s).to include("Sender account not found")
    end
  end
end