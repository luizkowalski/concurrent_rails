# Changelog

## 0.9.0

- **Breaking**: `then` and `chain` now return a new `ConcurrentRails::Promises` instance instead of mutating the receiver, matching `Concurrent::Promises` immutability. Chained call styles (`future { }.then { }.value`) keep working; branching multiple chains off the same future now works correctly instead of silently chaining off the previous `then`'s result
- Replaced all usage of concurrent-ruby private APIs (`wait_until_resolved`, `add_callback`) with public equivalents (`wait`, `on_fulfillment!`/`on_rejection!`/`on_resolution!`), removing breakage risk on concurrent-ruby upgrades
- `ConcurrentRails::Testing` modes now also apply to `delay` and `schedule` (previously only `future`)
- `ConcurrentRails::Testing` block forms are now thread-isolated (via `ActiveSupport::IsolatedExecutionState`), restore the previous mode on exit even when the block raises, and no longer clobber a global mode set with `immediate!`/`fake!`
- Declared `concurrent-ruby` as an explicit gem dependency
- Removed empty `ConcurrentRails::Railtie`
- README rewritten to drop the long-removed `ConcurrentRails::Future` and `ConcurrentRails::Multi`, document combinators/`schedule`, fix the swapped bang/non-bang callback description, and add caveats about `CurrentAttributes` and blocking waits

## 0.8.0

- Task blocks (futures, delays, `then`, `chain`, and all callbacks) are now wrapped in `Rails.application.executor.wrap` at execution time, not just at scheduling time. This ensures ActiveRecord connections are properly returned to the pool after each task runs on a thread pool thread.
- Added `zip` and `any_resolved_future` combinators to `ConcurrentRails::Promises`
- Added `fulfilled_future` and `rejected_future` factory methods to `ConcurrentRails::Promises`
- Added `schedule` and `schedule_on` for timed future execution
- Removed `permit_concurrent_loads` — it has been a no-op since Zeitwerk became the default autoloader
- Fixed `ConcurrentRails::Testing` block forms (`immediate {}`, `fake {}`, `real {}`) incorrectly resetting `execution_mode` to the symbol `:real` instead of the string `"real"`, causing `real?` to always return `false` after a scoped block

## 0.7.1

- Minimum Rails version bumped to 7.2

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
