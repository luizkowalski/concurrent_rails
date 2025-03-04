# Changelog

## 0.7.0

- Minimum Rails version bumped to 7.0
- Marked as Rails 8 compatible

## 0.6.1

- Fixed missing `ConcurrentRails` module definition

## 0.6.0

- Added tests for Rails 7.2
- Removed deprecated `ConcurrentRails::Future` class and `ConcurrentRails::Multi`. Use `ConcurrentRails::Promises` instead.

## 0.5.1

- Yanked 0.5.0

## 0.5.0

- Dropped support for Rails 5.2

## 0.4.1

- The gem no longer depends on `rails`. Instead, it depends on `railties`.

## 0.4.0

- Dropped support to Ruby 2.6 as it reached EOL 6 months ago.

## 0.3.0

- Updated dependencies
- Added Rails 7 to the test matrix
- Changed `ConcurrentRails::Testing` behavior: methods with bang now set the strategy globally while methods without bang will set the strategy just for the given block
- Enforcing `Style/ClassAndModuleChildren` rule to compact

## 0.2.1

- Added `ConcurrentRails::Testing` tool
- Dropped support for Ruby 2.5
- Added deprecation warning for `ConcurrentRails::Future`
- Wrapped `touch` and `wait` on Rails' executor as well

## 0.2.0

- Added delayed futures
- Added support for callbacks
- Code re-organization

## 0.1.8

- Use the same executor for all `Promises` chaining methods
- Update development dependencies

## 0.1.7

- Added `chain` method to promises
- Fixed wrong method forwarding to `Promises`: `resolved?` instead of `complete?`

## 0.1.6

- Added support for `timeout` and `timeout_value` on `Promises#value`
- Added `future_on` on `Promises`, allowing the user to pass a custom executor
- Default executor for `Future` is now `:fast` instead of `:io`
- Code cleanup

## 0.1.5

- Added `value!` to `ConcurrentRails::Future`
- Updated development dependencies

## 0.1.4

- Fixed `ConcurrentRails::Promises`'s `future` factory so it handles parameters and blocks correctly

## 0.1.3

- Dropped support for Ruby and Rails versions that reached EOL

## 0.1.2

- Fixed dependencies for development

## 0.1.1

- Hello world
