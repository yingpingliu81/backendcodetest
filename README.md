## Getting started

```sh
bundle install
bundle exec ruby bin/run
```

Defaults to the sample files in `data/`. Pass your own:

```sh
bundle exec ruby bin/run path/to/account_balances.csv path/to/transactions.csv
```

## Running the tests

```sh
bundle exec rspec
```

## Architecture

Small, single-purpose classes wired together in `bin/run` (the composition root):

| Layer | Class(es) | Responsibility |
|---|---|---|
| Models | `Account`, `Transaction`, `TransactionResult`, `TransactionError` | Domain objects; money is `BigDecimal` throughout |
| Loaders | `CsvAccountLoader`, `CsvTransactionLoader` | CSV → domain objects; both satisfy the `Loader` contract |
| Repository | `AccountRepository` | In-memory `Hash`-backed store; O(1) lookup by account number |
| Service | `TransactionProcessor` | Validates then executes one transfer |
| Reporter | `Reporter` | Formats and prints results + final balances |

Each layer has exactly one reason to change — loading, processing, and reporting are
fully separated and never bleed into each other.

`Account` is the only mutable object: its `balance` changes as transfers are applied.
Everything else — `Transaction`, `TransactionResult`, account numbers — is immutable once
constructed, making the data flow easy to reason about.

## Performance

**Overall time complexity: O(N + M)** — linear in the number of accounts (N) and transactions (M).

| Step | Complexity | Reason |
|---|---|---|
| Load N accounts into repository | O(N) | One `Hash` insert per row |
| Look up sender / receiver per transaction | O(1) | `Hash` lookup by account number |
| Validate + debit + credit per transaction | O(1) | Arithmetic only |
| Process M transactions | O(M) | One processor call per row |
| Print results + balances | O(M + N) | One pass over each collection |

- **Row-by-row CSV reading** — `CsvAccountLoader` returns an `Enumerator::Lazy`; `CsvTransactionLoader`
  returns a plain `Enumerator`. Both stream one row at a time so peak memory stays flat regardless of file size.

## Concurrency

This is a single-threaded batch job — no locking is needed. If the logic ever moved to a
multi-threaded service (e.g. a Rails API) backed by `accounts` and `transactions` database
tables, the `sufficient_funds?` + `debit` pair would be a race condition: two threads could
both read the same balance row, pass the check, and write back — resulting in an overdraft.
The fix is to wrap the read-modify-write in a database transaction with pessimistic locking
(`SELECT ... FOR UPDATE`) on the `accounts` row, so concurrent transfers on the same account
serialise and a failed transfer rolls back both the debit and the corresponding `transactions`
record atomically.
