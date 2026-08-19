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
    it "defines five error codes" do
      expect(CODES.size).to eq(5)
    end

    it "defines each code as a Symbol" do
      CODES.each { |code| expect(code).to be_a(Symbol) }
    end

    it "defines unique codes" do
      expect(CODES.uniq.size).to eq(CODES.size)
    end
  end

  describe ".message_for" do
    it "returns the correct message for every code" do
      EXPECTED_MESSAGES.each do |code, message|
        expect(described_class.message_for(code)).to eq(message)
      end
    end

    it "returns a fallback message for an unknown code" do
      expect(described_class.message_for(:bogus)).to eq("Unknown error")
    end
  end
end