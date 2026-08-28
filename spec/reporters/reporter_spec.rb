require "spec_helper"
require "models/account"
require "models/transaction"
require "models/transaction_result"
require "reporters/reporter"

RSpec.describe Reporter do
  let(:account) { Account.new(number: "1111234522226789", balance: BigDecimal("4900.00")) }
  let(:transaction) do
    Transaction.new(
      from_account_number: "1111234522226789",
      to_account_number: "1212343433335665",
      amount: "100.00",
      row_number: 1
    )
  end

  let(:success_result) { TransactionResult.new(transaction: transaction, success: true) }

  let(:insufficient_funds_result) do
    TransactionResult.new(transaction: transaction, success: false, error_code: TransactionResult::INSUFFICIENT_FUNDS)
  end
  let(:sender_not_found_result) do
    TransactionResult.new(transaction: transaction, success: false, error_code: TransactionResult::SENDER_NOT_FOUND)
  end
  let(:receiver_not_found_result) do
    TransactionResult.new(transaction: transaction, success: false, error_code: TransactionResult::RECEIVER_NOT_FOUND)
  end
  let(:self_transfer_result) do
    TransactionResult.new(transaction: transaction, success: false, error_code: TransactionResult::SELF_TRANSFER)
  end
  let(:invalid_amount_result) do
    TransactionResult.new(transaction: transaction, success: false, error_code: TransactionResult::INVALID_AMOUNT)
  end

  subject(:reporter) { described_class.new }

  describe "#print_results" do
    it "prints a success result" do
      expect { reporter.print_results([success_result]) }.to output(/row 1: success/).to_stdout
    end

    context "with a failure result" do
      it "reports insufficient funds" do
        expect { reporter.print_results([insufficient_funds_result]) }
          .to output(/Insufficient funds/).to_stdout
      end

      it "reports sender not found" do
        expect { reporter.print_results([sender_not_found_result]) }
          .to output(/Sender account not found/).to_stdout
      end

      it "reports receiver not found" do
        expect { reporter.print_results([receiver_not_found_result]) }
          .to output(/Receiver account not found/).to_stdout
      end

      it "reports self transfer" do
        expect { reporter.print_results([self_transfer_result]) }
          .to output(/Cannot transfer to the same account/).to_stdout
      end

      it "reports invalid amount" do
        expect { reporter.print_results([invalid_amount_result]) }
          .to output(/Amount must be a positive number/).to_stdout
      end
    end
  end

  describe "#print_balances" do
    it "prints the account number and final balance" do
      expect { reporter.print_balances([account]) }.to output(/1111234522226789/).to_stdout
      expect { reporter.print_balances([account]) }.to output(/4900\.00/).to_stdout
    end
  end
end