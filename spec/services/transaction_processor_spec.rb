require "spec_helper"
require "models/account"
require "models/transaction"
require "models/transaction_error"
require "models/transaction_result"
require "repositories/account_repository"
require "services/transaction_processor"

RSpec.describe TransactionProcessor do
  let(:sender) { Account.new(number: "1111234522226789", balance: BigDecimal("5000.00")) }
  let(:receiver) { Account.new(number: "1212343433335665", balance: BigDecimal("1200.00")) }
  let(:account_repository) { instance_double(AccountRepository, find: nil) }

  subject(:processor) { described_class.new(account_repository) }

  def build_transaction(amount:, from: sender.number, to: receiver.number, row_number: 1)
    Transaction.new(from_account_number: from, to_account_number: to, amount: amount, row_number: row_number)
  end

  before do
    allow(account_repository).to receive(:find).with(sender.number).and_return(sender)
    allow(account_repository).to receive(:find).with(receiver.number).and_return(receiver)
  end

  describe "#process" do
    context "when all checks pass" do
      it "returns a success TransactionResult" do
        result = processor.process(build_transaction(amount: "100.00"))
        expect(result.success?).to be(true)
        expect(result.error_code).to be_nil
      end

      it "debits the sender and credits the receiver" do
        processor.process(build_transaction(amount: "100.00"))
        expect(sender.balance).to eq(BigDecimal("4900.00"))
        expect(receiver.balance).to eq(BigDecimal("1300.00"))
      end
    end

    context "when the sender is unknown" do
      it "returns a SENDER_NOT_FOUND failure without mutating balances" do
        result = processor.process(build_transaction(from: "9999999999999999", amount: "100.00"))
        expect(result.success?).to be(false)
        expect(result.error_code).to eq(TransactionError::SENDER_NOT_FOUND)
        expect(sender.balance).to eq(BigDecimal("5000.00"))
        expect(receiver.balance).to eq(BigDecimal("1200.00"))
      end
    end

    context "when the receiver is unknown" do
      it "returns a RECEIVER_NOT_FOUND failure without mutating balances" do
        result = processor.process(build_transaction(to: "9999999999999999", amount: "100.00"))
        expect(result.success?).to be(false)
        expect(result.error_code).to eq(TransactionError::RECEIVER_NOT_FOUND)
        expect(sender.balance).to eq(BigDecimal("5000.00"))
        expect(receiver.balance).to eq(BigDecimal("1200.00"))
      end
    end

    context "when the sender and receiver are the same account" do
      it "returns a SELF_TRANSFER failure without mutating balances" do
        result = processor.process(build_transaction(from: sender.number, to: sender.number, amount: "100.00"))
        expect(result.success?).to be(false)
        expect(result.error_code).to eq(TransactionError::SELF_TRANSFER)
        expect(sender.balance).to eq(BigDecimal("5000.00"))
      end
    end

    context "with a non-positive amount" do
      it "returns an INVALID_AMOUNT failure for zero without mutating balances" do
        result = processor.process(build_transaction(amount: "0"))
        expect(result.success?).to be(false)
        expect(result.error_code).to eq(TransactionError::INVALID_AMOUNT)
        expect(sender.balance).to eq(BigDecimal("5000.00"))
        expect(receiver.balance).to eq(BigDecimal("1200.00"))
      end

      it "returns an INVALID_AMOUNT failure for a negative amount without mutating balances" do
        result = processor.process(build_transaction(amount: "-100.00"))
        expect(result.success?).to be(false)
        expect(result.error_code).to eq(TransactionError::INVALID_AMOUNT)
        expect(sender.balance).to eq(BigDecimal("5000.00"))
        expect(receiver.balance).to eq(BigDecimal("1200.00"))
      end
    end

    context "when funds are insufficient" do
      it "returns an INSUFFICIENT_FUNDS failure without mutating balances" do
        result = processor.process(build_transaction(amount: "5000.01"))
        expect(result.success?).to be(false)
        expect(result.error_code).to eq(TransactionError::INSUFFICIENT_FUNDS)
        expect(sender.balance).to eq(BigDecimal("5000.00"))
        expect(receiver.balance).to eq(BigDecimal("1200.00"))
      end
    end
  end
end