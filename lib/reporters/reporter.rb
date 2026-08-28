class Reporter
  def print_results(result)
    puts result
  end

  def print_balances(accounts)
    accounts.each do |account|
      printf("%-16s  $%s\n", account.number, format("%.2f", account.balance))
    end
  end
end