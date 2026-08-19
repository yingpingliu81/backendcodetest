class Reporter
  def initialize(account_repository, results)
    @account_repository = account_repository
    @results = results
  end

  def print_results
    @results.each { |result| puts result }
  end

  def print_balances
    @account_repository.all.each do |account|
      printf("%-16s  $%s\n", account.number, format("%.2f", account.balance))
    end
  end
end