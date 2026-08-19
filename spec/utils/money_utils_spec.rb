require "spec_helper"
require "utils/money_utils"

RSpec.describe MoneyUtils do
  describe ".coerce_decimal" do
    it "returns a BigDecimal unchanged" do
      big = BigDecimal("500.00")
      expect(described_class.coerce_decimal(big)).to equal(big)
    end

    it "converts a numeric String to BigDecimal" do
      expect(described_class.coerce_decimal("500.00")).to eq(BigDecimal("500.00"))
    end

    it "converts a Float to BigDecimal" do
      expect(described_class.coerce_decimal(500.0)).to eq(BigDecimal("500.00"))
    end

    it "converts an Integer to BigDecimal" do
      expect(described_class.coerce_decimal(500)).to eq(BigDecimal("500"))
    end

    it "raises ArgumentError for non-numeric input" do
      expect { described_class.coerce_decimal("abc") }.to raise_error(ArgumentError)
    end

    it "raises ArgumentError for nil" do
      expect { described_class.coerce_decimal(nil) }.to raise_error(ArgumentError)
    end
  end

  describe ".validate_amount!" do
    it "accepts a positive amount" do
      expect { described_class.validate_amount!(BigDecimal("10")) }.not_to raise_error
    end

    it "rejects a zero amount" do
      expect { described_class.validate_amount!(BigDecimal("0")) }
        .to raise_error(ArgumentError, /positive/)
    end

    it "rejects a negative amount" do
      expect { described_class.validate_amount!(BigDecimal("-10")) }
        .to raise_error(ArgumentError, /positive/)
    end

    it "coerces a String amount before validating" do
      expect { described_class.validate_amount!("10") }.not_to raise_error
    end
  end
end