require "spec_helper"
require "models/account"

RSpec.describe Account do
  let(:number) { "1111234522226789" }
  let(:balance) { BigDecimal("5000.00") }
  subject(:account) { described_class.new(number: number, balance: balance) }

  describe "attributes" do
    it "exposes the account number as a String" do
      expect(account.number).to eq(number)
    end

    it "treats the account number as immutable identity" do
      expect(account.number).to be_frozen
      expect { account.number << "0" }.to raise_error(FrozenError)
    end

    it "exposes the balance as a BigDecimal" do
      expect(account.balance).to eq(balance)
      expect(account.balance).to be_a(BigDecimal)
    end

    it "does not expose a public balance writer" do
      expect(account).not_to respond_to(:balance=)
    end

    it "coerces a String balance to BigDecimal" do
      string_account = described_class.new(number: number, balance: "5000.00")
      expect(string_account.balance).to eq(balance)
      expect(string_account.balance).to be_a(BigDecimal)
    end
  end

  describe "#sufficient_funds?" do
    it "is true when the balance covers the amount" do
      expect(account.sufficient_funds?(BigDecimal("100"))).to be(true)
    end

    it "is true when the amount exactly equals the balance" do
      expect(account.sufficient_funds?(BigDecimal("5000"))).to be(true)
    end

    it "is false when the amount exceeds the balance" do
      expect(account.sufficient_funds?(BigDecimal("5000.01"))).to be(false)
    end

    context "with a non-positive amount" do
      it "rejects a zero amount" do
        expect { account.sufficient_funds?(BigDecimal("0")) }
          .to raise_error(ArgumentError, /positive/)
      end

      it "rejects a negative amount" do
        expect { account.sufficient_funds?(BigDecimal("-100")) }
          .to raise_error(ArgumentError, /positive/)
      end
    end

    it "raises ArgumentError for invalid decimal input" do
      expect { account.sufficient_funds?("abc") }.to raise_error(ArgumentError)
    end
  end

  describe "#debit" do
    it "reduces the balance by the amount" do
      expect { account.debit(BigDecimal("500")) }
        .to change(account, :balance).from(balance).to(BigDecimal("4500.00"))
    end

    it "coerces a String amount to BigDecimal" do
      expect { account.debit("500") }
        .to change(account, :balance).to(BigDecimal("4500.00"))
    end

    context "when the amount exactly equals the balance" do
      it "debits down to zero without raising" do
        expect { account.debit(balance) }.not_to raise_error
        expect(account.balance).to eq(BigDecimal("0"))
      end
    end

    context "when funds are insufficient" do
      it "raises InsufficientFundsError and does not change the balance" do
        expect { account.debit(BigDecimal("5000.01")) }
          .to raise_error(Account::InsufficientFundsError, /insufficient funds: balance/)
        expect(account.balance).to eq(balance)
      end
    end

    context "with a non-positive amount" do
      it "rejects a zero amount without changing the balance" do
        expect { account.debit(BigDecimal("0")) }
          .to raise_error(ArgumentError, /positive/)
        expect(account.balance).to eq(balance)
      end

      it "rejects a negative amount without changing the balance" do
        expect { account.debit(BigDecimal("-100")) }
          .to raise_error(ArgumentError, /positive/)
        expect(account.balance).to eq(balance)
      end
    end

    it "raises ArgumentError for invalid decimal input" do
      expect { account.debit("abc") }.to raise_error(ArgumentError)
    end

    it "coerces a Float amount" do
      expect { account.debit(500.0) }
        .to change(account, :balance).to(BigDecimal("4500.00"))
    end

    it "raises ArgumentError for a nil amount" do
      expect { account.debit(nil) }.to raise_error(ArgumentError)
    end
  end

  describe "#credit" do
    it "increases the balance by the amount" do
      expect { account.credit(BigDecimal("500")) }
        .to change(account, :balance).from(balance).to(BigDecimal("5500.00"))
    end

    it "coerces a String amount to BigDecimal" do
      expect { account.credit("500") }
        .to change(account, :balance).to(BigDecimal("5500.00"))
    end

    context "with a non-positive amount" do
it "rejects a zero amount" do
      expect { account.credit(BigDecimal("0")) }
        .to raise_error(ArgumentError, /positive/)
      expect(account.balance).to eq(balance)
    end

      it "rejects a negative amount" do
        expect { account.credit(BigDecimal("-100")) }
          .to raise_error(ArgumentError, /positive/)
      end
    end

    it "raises ArgumentError for invalid decimal input" do
      expect { account.credit("abc") }.to raise_error(ArgumentError)
    end

    it "coerces a Float amount" do
      expect { account.credit(500.0) }
        .to change(account, :balance).to(BigDecimal("5500.00"))
    end
  end

  describe "balance validation" do
    it "rejects a negative starting balance" do
      expect { described_class.new(number: number, balance: BigDecimal("-1")) }
        .to raise_error(ArgumentError, /negative/)
    end

    it "accepts a zero starting balance" do
      expect { described_class.new(number: number, balance: BigDecimal("0")) }
        .not_to raise_error
    end

    it "coerces a Float balance to BigDecimal" do
      float_account = described_class.new(number: number, balance: 5000.0)
      expect(float_account.balance).to eq(BigDecimal("5000.00"))
      expect(float_account.balance).to be_a(BigDecimal)
    end

    it "rejects a nil balance" do
      expect { described_class.new(number: number, balance: nil) }
        .to raise_error(ArgumentError)
    end
  end

  describe "account number validation" do
    it "accepts a 16-digit number" do
      expect { described_class.new(number: "1234567890123456", balance: BigDecimal("1")) }
        .not_to raise_error
    end

    it "accepts a 16-digit Integer and stores it as a String" do
      integer_account = described_class.new(number: 12_345_678_901_234_56, balance: BigDecimal("1"))
      expect(integer_account.number).to eq("1234567890123456")
    end

    it "raises ArgumentError for a number that is not 16 digits" do
      expect { described_class.new(number: "123", balance: BigDecimal("1")) }
        .to raise_error(ArgumentError, /16/)
    end

    it "raises ArgumentError for a 17-digit number" do
      expect { described_class.new(number: "12345678901234567", balance: BigDecimal("1")) }
        .to raise_error(ArgumentError, /16/)
    end

    it "raises ArgumentError for an empty string" do
      expect { described_class.new(number: "", balance: BigDecimal("1")) }
        .to raise_error(ArgumentError, /16/)
    end

    it "raises ArgumentError for nil" do
      expect { described_class.new(number: nil, balance: BigDecimal("1")) }
        .to raise_error(ArgumentError, /16/)
    end

    it "raises ArgumentError for a number containing non-digits" do
      expect { described_class.new(number: "123456789012345a", balance: BigDecimal("1")) }
        .to raise_error(ArgumentError, /16/)
    end
  end

  describe "#to_s" do
    it "includes the account number and formatted balance" do
      expect(account.to_s).to eq("1111234522226789: $5000.00")
    end
  end
end