require "models/transaction_error"

class TransactionResult
  attr_reader :transaction, :error_code

  def initialize(transaction:, success:, error_code: nil)
    @transaction = transaction
    @success = success
    @error_code = error_code
  end

  def success?
    @success
  end

  def error_message
    return nil if success?

    TransactionError.message_for(error_code)
  end

  def to_s
    return "row #{transaction.row_number}: success" if success?

    "row #{transaction.row_number}: failure (#{error_message})"
  end
end