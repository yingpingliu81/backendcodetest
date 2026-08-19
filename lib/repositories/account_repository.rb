class AccountRepository
  class DuplicateAccountError < StandardError; end

  def initialize
    @accounts = {}
  end

  # Duplicate-policy: Adding an duplicated account number raises DuplicateAccountError rather than silently overwriting.
  def add(account)
    raise DuplicateAccountError, "account #{account.number} already exists" if @accounts.key?(account.number)

    @accounts[account.number] = account
  end

  def find(account_number)
    @accounts[account_number.to_s]
  end

  def all
    @accounts.values
  end
end