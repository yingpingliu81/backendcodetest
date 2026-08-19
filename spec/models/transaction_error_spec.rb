require "spec_helper"
require "models/transaction_error"

RSpec.describe TransactionError do
  CODES = [
    TransactionError::SENDER_NOT_FOUND,
    TransactionError::RECEIVER_NOT_FOUND,
    TransactionError::SELF_TRANSFER,
    TransactionError::INVALID_AMOUNT,
    TransactionError::INSUFFICIENT_FUNDS
  ].freeze

  EXPECTED_MESSAGES = {
    TransactionError::SENDER_NOT_FOUND => "Sender account not found",
    TransactionError::RECEIVER_NOT_FOUND => "Receiver account not found",
    TransactionError::SELF_TRANSFER => "Cannot transfer to the same account",
    TransactionError::INVALID_AMOUNT => "Amount must be a positive number",
    TransactionError::INSUFFICIENT_FUNDS => "Insufficient funds"
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
end