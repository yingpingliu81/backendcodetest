require "bigdecimal"

module MoneyUtils
  def self.coerce_decimal(value)
    value.is_a?(BigDecimal) ? value : BigDecimal(value.to_s)
  end

  def self.validate_amount!(amount)
    amount = coerce_decimal(amount)
    raise ArgumentError, "amount must be positive" unless amount.positive?
  end
end