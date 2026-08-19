require "utils/money_utils"

class Transaction
  attr_reader :from_account_number, :to_account_number, :amount, :row_number

  def initialize(from_account_number:, to_account_number:, amount:, row_number:)
    @from_account_number = from_account_number.to_s.freeze
    @to_account_number = to_account_number.to_s.freeze
    @amount = MoneyUtils.coerce_decimal(amount)
    @row_number = row_number
  end
end