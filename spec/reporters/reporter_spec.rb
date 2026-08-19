require "spec_helper"
require "models/account"
require "models/transaction"
require "models/transaction_error"
require "models/transaction_result"
require "repositories/account_repository"
require "reporters/reporter"

RSpec.describe Reporter do
  let(:account) { Account.new(number: "1111234522226789", balance: BigDecimal("4900.00")) }
  let(:account_repository) { instance_double(AccountRepository, all: [account]) }
  let(:transaction) do
    Transaction.new(
      from_account_number: "1111234522226789",
      to_account_number: "1212343433335665",
      amount: "100.00",
      row_number: 1
    )
  end
  let(:success_result) { TransactionResult.new(transaction: transaction, success: true) }
  let(:failure_result) do
    TransactionResult.new(transaction: transaction, success: false, error_code: TransactionError::INSUFFICIENT_FUNDS)
  end

  subject(:reporter) { described_class.new(account_repository, [success_result, failure_result]) }

  describe "#print_results" do
    it "prints each transaction result to stdout" do
      expect { reporter.print_results }.to output(/row 1: success/).to_stdout
      expect { reporter.print_results }.to output(/Insufficient funds/).to_stdout
    end
  end

  describe "#print_balances" do
    it "prints the account number and final balance" do
      expect { reporter.print_balances }.to output(/1111234522226789/).to_stdout
      expect { reporter.print_balances }.to output(/4900\.00/).to_stdout
    end
  end
end