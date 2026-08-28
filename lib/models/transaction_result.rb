class TransactionResult
  # Error code registry (previously TransactionError)
  SENDER_NOT_FOUND   = :sender_not_found
  RECEIVER_NOT_FOUND = :receiver_not_found
  SELF_TRANSFER      = :self_transfer
  INVALID_AMOUNT     = :invalid_amount
  INSUFFICIENT_FUNDS = :insufficient_funds

  MESSAGES = {
    SENDER_NOT_FOUND   => "Sender account not found",
    RECEIVER_NOT_FOUND => "Receiver account not found",
    SELF_TRANSFER      => "Cannot transfer to the same account",
    INVALID_AMOUNT     => "Amount must be a positive number",
    INSUFFICIENT_FUNDS => "Insufficient funds"
  }.freeze

  FALLBACK_MESSAGE = "Unknown error"

  def self.message_for(code)
    MESSAGES.fetch(code, FALLBACK_MESSAGE)
  end

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

    self.class.message_for(error_code)
  end

  def to_s
    return "row #{transaction.row_number}: success" if success?

    "row #{transaction.row_number}: failure (#{error_message})"
  end
end