require "models/transaction_error"
require "models/transaction_result"

class TransactionProcessor
  def initialize(account_repository)
    @account_repository = account_repository
  end

  def process(transaction)
    sender = @account_repository.find(transaction.from_account_number)
    return failed(transaction, TransactionError::SENDER_NOT_FOUND) unless sender

    receiver = @account_repository.find(transaction.to_account_number)
    return failed(transaction, TransactionError::RECEIVER_NOT_FOUND) unless receiver

    return failed(transaction, TransactionError::SELF_TRANSFER) if transaction.from_account_number == transaction.to_account_number
    return failed(transaction, TransactionError::INVALID_AMOUNT) if transaction.amount <= 0
    return failed(transaction, TransactionError::INSUFFICIENT_FUNDS) unless sender.sufficient_funds?(transaction.amount)

    sender.debit(transaction.amount)
    receiver.credit(transaction.amount)
    TransactionResult.new(transaction: transaction, success: true)
  end

  private

  def failed(transaction, error_code)
    TransactionResult.new(transaction: transaction, success: false, error_code: error_code)
  end
end