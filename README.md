# DBLock

[![Gem Version](https://badge.fury.io/rb/db_lock.svg)](https://badge.fury.io/rb/db_lock)
[![Tests](https://github.com/mkon/db_lock/actions/workflows/test.yml/badge.svg)](https://github.com/mkon/db_lock/actions/workflows/test.yml)

Gem to obtain and release manual db locks. This can be utilized for example to make sure that certain rake tasks do not run in parallel on the same database (for example when cron jobs run for too long or are accidentally started multiple times). Currently only supports:

- MySQL
- Microsoft SQL Server
- Postgres

## Installation

Add this line to your application's Gemfile:

    gem 'db_lock'

then run `bundle`

## Usage

```ruby
DBLock::Lock.get('name_of_lock', 5) do
  # code here
end
```

Before the code block is executed, it will attempt to acquire a db lock for X seconds (5 in this example). If this fails it will raise an `DBLock::AlreadyLocked` error. The lock is released after the block is executed, even if the block raised an error itself.

The current implementation uses a class variable to store lock state so it is not thread-safe when using multiple threads to acquire/release locks.

Locks are achieved on the database via:

| Database  | Locking method   |
|-----------|------------------|
| MySQL     | GET_LOCK         |
| Postgres  | pg_advisory_lock |
| SQLServer | sp_getapplock    |

## Dynamic lock name

If you prefix the lock with a `.` in a Rails application, `.` will be automatically replaced with `YourAppName.environment` (production/development/etc).
If the lock name exceeds 64 characters, it will be replaced with a lock name of 64 characters, that consists of a pre- and suffix from the original lock name and a middle MD5 checksum.


## Development

Bundle with the adapter you want to use, for example

```bash
$ bundle --with mysql
```

Run rspec with the database url env variables set. It will only run the specs it can run and skip the others.

For example
```bash
$ MYSQL_URL=mysql2://root:dummy@localhost/test SQLSERVER_URL=sqlserver://root:dummy@localhost/test rspec
```
