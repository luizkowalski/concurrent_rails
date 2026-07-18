# ConcurrentRails

![status](https://github.com/luizkowalski/concurrent_rails/actions/workflows/ruby.yml/badge.svg?branch=main)

Multithread is hard. [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) did an amazing job implementing the concepts of multithread in the Ruby world. The problem is that Rails doesn't play nice with it. Rails has a complex way of managing threads called Executor and concurrent-ruby (most specifically, [Future](https://github.com/ruby-concurrency/concurrent-ruby/blob/master/docs-source/future.md)) does not work seamlessly with it.

The goal of this gem is to provide a simple library that allows the developer to work with Futures without having to care about Rails's Executor and the whole pack of problems that come with it: autoload, thread pools, active record connections, etc.

## Usage

This library provides `ConcurrentRails::Promises`, a Rails-aware wrapper around [`Concurrent::Promises`](https://ruby-concurrency.github.io/concurrent-ruby/master/Concurrent/Promises.html), plus `ConcurrentRails::Testing` helpers for your test suite.

### Promises

All you have to do is call `#future` and pass a block to be executed asynchronously:

```ruby
irb(main):001:0> future = ConcurrentRails::Promises.future(5) { |v| sleep(v); 42 }
=> #<ConcurrentRails::Promises:0x00007fed68db66b0 @future_instance=#<Concurrent::Promises::Future

irb(main):002:0> future.state
=> :pending

# After the process slept for 5 seconds
irb(main):003:0> future.state
=> :fulfilled

irb(main):004:0> future.value
=> 42
```

The benefit of `Promises` over a pure `Future` class is that you can chain futures without blocking the main thread.

```ruby
irb(main):001:0> future = ConcurrentRails::Promises.future { 42 }.then { |v| v * 2 }
=> #<ConcurrentRails::Promises:0x00007fe92eba3460 @instance=#...
irb(main):002:0> future.value
=> 84
```

`then` and `chain` return a **new** `ConcurrentRails::Promises` instance and leave the receiver untouched, matching `Concurrent::Promises` semantics. This means you can branch multiple chains off the same future:

```ruby
root    = ConcurrentRails::Promises.future { expensive_call }
doubled = root.then { |v| v * 2 }
tripled = root.then { |v| v * 3 } # branches off root, not doubled
```

### Combinators and factories

`zip` and `any_resolved_future` combine multiple promises; `fulfilled_future` and `rejected_future` create already-resolved ones:

```ruby
a = ConcurrentRails::Promises.future { 1 }
b = ConcurrentRails::Promises.future { 2 }

ConcurrentRails::Promises.zip(a, b).value                 # => [1, 2]
ConcurrentRails::Promises.any_resolved_future(a, b).value # => first to settle
ConcurrentRails::Promises.fulfilled_future(42).value      # => 42
```

### Scheduled futures

`schedule` runs a task after the given delay (in seconds):

```ruby
ConcurrentRails::Promises.schedule(10) { cleanup! }
```

### Delayed futures

A delayed future is a Future that is enqueued but not run until `#touch` or any other method that requires a resolution is called.

```ruby
irb(main):002:0> delay = ConcurrentRails::Promises.delay { 42 }
=> #<ConcurrentRails::Promises:0x00007f8b55333d48 @executor=:io, @instan...

irb(main):003:0> delay.state
=> :pending

irb(main):004:0> delay.touch
=> #<ConcurrentRails::Promises:0x00007f8b55333d48 ...

irb(main):005:0> delay.state
=> :fulfilled

irb(main):006:0> delay.value
=> 42
```

Three methods will trigger a resolution: `#touch`, `#value` and `#wait`: `#touch` will simply trigger the execution but won't block the main thread, while `#wait` and `#value` will block the main thread until a resolution is given.

### Callbacks

Delayed and regular futures can set a callback to be executed after the resolution of the future. There are three different callbacks:

* `on_resolution`: runs after the Future is resolved and yields three parameters to the callback in the following order: `true/false` for future's fulfillment, `value` as the result of the future execution, and `reason`, that will be `nil` if the future fulfilled or the error that the future triggered.

* `on_fulfillment`: runs after the Future is fulfilled and yields `value` to the callback

* `on_rejection`: runs after the future is rejected and yields the `error` to the callback

```ruby
delay = ConcurrentRails::Promises.delay { complex_find_user_query }.
        on_fulfillment { |user| user.update!(name: 'John Doe') }.
        on_rejection { |reason| log_error(reason) }

delay.touch
```

All of these callbacks have a bang version (e.g. `on_fulfillment!`). The bang version runs the callback synchronously on the thread that resolved the future, while the version without bang runs it asynchronously on the promise's executor.

## Caveats

* `Current` attributes (`ActiveSupport::CurrentAttributes`) are **not** propagated to the future's thread. Each task runs inside `Rails.application.executor.wrap`, which resets per-execution state, so `Current.user` and friends will be `nil` inside the block. Pass what you need as arguments instead.
* `#value` and `#wait` block the calling thread. In development, a thread blocked inside a future wait counts as a running execution, so code reloading has to wait for it. Prefer `#touch` plus callbacks when you don't need the result immediately.

## Testing

If you are using RSpec, you will notice that it might not play well with threads. ActiveRecord opens a database connection for every thread and since RSpec tests are wrapped in a transaction, by the time your promise tries to access something on the database, for example, a user, gems like Database Cleaner probably already triggered and deleted the user, resulting in `ActiveRecord::RecordNotFound` errors. You have a couple of solutions like disabling transactional fixtures if you are using it or update the Database Cleaner strategy (that will result in much slower tests).
Since none of these solutions were satisfactory to me, I created `ConcurrentRails::Testing` with two strategies: `immediate` and `fake`. When you wrap a Promise's `future` with `immediate`, the executor gets replaced from `:io` to `:immediate`. It still returns a promise anyway. This is not the case with `fake` strategy: it executes the task outside the `ConcurrentRails` engine and returns whatever `.value` would return:

`immediate` strategy:

```ruby
irb(main):001:1* result = ConcurrentRails::Testing.immediate do
irb(main):002:1*       ConcurrentRails::Promises.future { 42 }
irb(main):003:0> end
=>
#<ConcurrentRails::Promises:0x000000013e5fc870
...
irb(main):004:0> result.class
=> ConcurrentRails::Promises # <-- Still a `ConcurrentRails::Promises` class
irb(main):005:0> result.executor
=> :immediate # <-- default executor (:io) gets replaced
```

`fake` strategy:

```ruby
irb(main):001:1* result = ConcurrentRails::Testing.fake do
irb(main):002:1*       ConcurrentRails::Promises.future { 42 }
irb(main):003:0> end
=> 42 # <-- yields the task but does not return a Promise
irb(main):004:0> result.class
=> Integer
```

Both strategies also apply to `delay` and `schedule` (`fake` runs a scheduled task right away, ignoring the delay).

The block form only changes the mode for the current thread and restores the previous mode when the block exits, even if it raises. You can also set the strategy globally using `ConcurrentRails::Testing.fake!` or `ConcurrentRails::Testing.immediate!`, and reset it with `ConcurrentRails::Testing.real!`

## Further reading

For more information on how Futures works and how Rails handles multithread check these links:

[Future documentation](https://github.com/ruby-concurrency/concurrent-ruby/blob/master/docs-source/future.md)

[Threading and code execution on rails](https://guides.rubyonrails.org/threading_and_code_execution.html)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'concurrent_rails', '~> 0.9'
```

And then execute:

```bash
bundle
```

Or install it yourself as:

```bash
gem install concurrent_rails
```

## Contributing

Pull requests are always welcome


## Updating Ruby or Rails versions using Appraisal

This gem uses Appraisal for multiple Ruby and Rails versions testing. To update the Ruby or Rails versions, you can run:

```bash
bundle exec appraisal install
```

and to run the tests for all versions, you can run:

```bash
bundle exec appraisal rake test
```

Check the [usage](https://github.com/thoughtbot/appraisal?tab=readme-ov-file#usage) section of the Appraisal gem for more information on how to use it.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
