require "utils/money_utils"

class Account
  class InsufficientFundsError < StandardError; end

  ACCOUNT_NUMBER_PATTERN = /\A\d{16}\z/

  # number is immutable identity; balance is mutable state.
  attr_reader :number, :balance

  def initialize(number:, balance:)
    validate_number!(number)
    @number = number.to_s.dup.freeze
    @balance = MoneyUtils.coerce_decimal(balance)
    validate_balance!
  end

  def sufficient_funds?(amount)
    amount = coerce_and_validate!(amount)
    @balance >= amount
  end

  def debit(amount)
    raise InsufficientFundsError,
          "insufficient funds: balance #{@balance}" unless sufficient_funds?(amount)

    @balance -= MoneyUtils.coerce_decimal(amount)
  end

  def credit(amount)
    amount = coerce_and_validate!(amount)
    @balance += amount
  end

  def to_s
    "#{@number}: $#{format("%.2f", @balance)}"
  end

  private

  def validate_number!(number)
    raise ArgumentError, "account number must be 16 digits" unless number.to_s.match?(ACCOUNT_NUMBER_PATTERN)
  end

  def validate_balance!
    raise ArgumentError, "balance cannot be negative" if @balance.negative?
  end

  def coerce_and_validate!(amount)
    amount = MoneyUtils.coerce_decimal(amount)
    MoneyUtils.validate_amount!(amount)
    amount
  end
end