# ConcurrentRails

![status](https://github.com/luizkowalski/concurrent_rails/actions/workflows/ruby.yml/badge.svg?branch=master)

Multithread is hard. [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) did an amazing job implementing the concepts of multithread in the Ruby world. The problem is that Rails doesn't play nice with it. Rails has a complex way of managing threads called Executor and concurrent-ruby (most specifically, [Future](https://github.com/ruby-concurrency/concurrent-ruby/blob/master/docs-source/future.md)) does not work seamlessly with it.

The goal of this gem is to provide a simple library that allows the developer to work with Futures without having to care about Rails's Executor and the whole pack of problems that come with it: autoload, thread pools, active record connections, etc.

## Usage

This library provides three classes that will help you run tasks in parallel: `ConcurrentRails::Promises`,  `ConcurrentRails::Future` ([in process of being deprecated by concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby#deprecated)) and `ConcurrentRails::Multi`

### Promises

`Promises` is the recommended way from `concurrent-ruby` to create `Future`s as `Concurrent::Future` will be deprecated at some point. All you have to do is call `#future` and pass a block to be executed asynchronously:

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
=> #<ConcurrentRails::Promises:0x00007fe92eba3460 @future_instance=#...
irb(main):002:0> future.value
=> 84
```

### Delayed futures

Delayed future is a future that is enqueued but not run until `#touch` or any other method that requires a resolution is called.

```ruby
irb(main):002:0> delay = ConcurrentRails::Promises.delay { 42 }
=> #<ConcurrentRails::Promises:0x00007f8b55333d48 @executor=:io, @instan...

irb(main):003:0> delay.state
=> :pending

irb(main):004:0> delay.touch
=> #<Concurrent::Promises::Future:0x00007f8b553325b0 pending>

irb(main):005:0> delay.state
=> :fulfilled

irb(main):006:0> delay.value
=> 42
```

Three methods will trigger a resolution: `#touch`, `#value` and `#wait`: `#touch` will simply trigger the execution but won't block the main thread, while `#wait` and `#value` will block the main thread until a resolution is given.

### Callbacks

Delayed and regular futures can set a callback to be executed after the resolution of the future. There are three different callbacks:

* `on_resolution`: runs after the future is resolved and yields three parameters to the callback in the following order: `true/false` for future's fulfillment, `value` as the result of the future execution, and `reason`, that will be `nil` if the future fulfilled or the error that the future triggered.

* `on_fulfillment`: runs after the future is fulfilled and yields `value` to the callback

* `on_rejection`: runs after the future is rejected and yields the `error` to the callback

```ruby
delay = ConcurrentRails::Promises.delay { complex_find_user_query }.
        on_fulfillment { |user| user.update!(name: 'John Doe') }.
        on_rejection { |reason| log_error(reason) }

delay.touch
```

All of these callbacks have a bang version (e.g. `on_fulfillment!`). The bang version will execute the callback on the same thread pool that was initially set up and the version without bang will run asynchronously on a different executor.

### (Deprecated) Future

`ConcurrentRails::Future` will execute your code in a separate thread and you can check the progress of it whenever you need it. When the task is ready, you can access the result with `#result` function:

```ruby
irb(main):001:0> future = ConcurrentRails::Future.new do
  sleep(5) # Simulate a long running task
  42
end

# at this point, nothing has happened yet.

irb(main):002:0> future.execute

irb(main):003:0> future.state
=> :processing

# after 5 seconds
irb(main):004:0> future.state
=> :fulfilled

irb(main):005:0> future.value
=> 42
```

A task can also fail. In this case, the state of the future will be `rejected` and the exception can be accessed by invoking `reason`

```ruby
irb(main):001:1* future = ConcurrentRails::Future.new do
irb(main):002:1*   2 / 0
irb(main):003:0> end.execute

=> #<ConcurrentRails::Future...

irb(main):004:0> future.state
=> :rejected

irb(main):005:0> future.reason
=> #<ZeroDivisionError: divided by 0>
```

### (Deprecated) Multi

`ConcurrentRails::Multi` will let you execute multiple tasks in parallel and aggregate the results of each task when they are done. `Multi` accepts an undefined number of `Proc`s.

```ruby
irb(main):001:1* multi = ConcurrentRails::Multi.enqueue(
irb(main):002:1*   -> { 42 },
irb(main):003:1*   -> { :multi_test }
irb(main):004:0> )

=> #<ConcurrentRails::Multi:0x00007fbc3f9ca3f8 @actions=[#<Proc:0x00007fbc3f9ca470..
irb(main):005:0> multi.complete?
=> true

irb(main):006:0> multi.compute
=> [42, :multi_test]
```

Given the fact that you can send any number of `Proc`s, the result from `compute` will always be an array, even if you provide only one proc.

```ruby
irb(main):007:1* multi = ConcurrentRails::Multi.enqueue(
irb(main):008:1*   -> { 42 }
irb(main):009:0> )
=> #<ConcurrentRails::Multi:0x00007fbc403f0b98 @actions=[#<Proc:0x00007...

irb(main):010:0> multi.compute
=> [42]
```

Same as `Future`, one of the `Multi` tasks can fail. You can access the exception by calling `#errors`:

```ruby
irb(main):001:1*  multi = ConcurrentRails::Multi.enqueue(
irb(main):002:1*    -> { 42 },
irb(main):003:1*    -> { 2 / 0 }
irb(main):004:0>  )
=> #<ConcurrentRails::Multi:0x00007fb46d3ee3a0 @actions=[#<Proc:0x00007..

irb(main):005:0> multi.complete?
=> true

irb(main):006:0> multi.compute
=> [42, nil]

irb(main):007:0> multi.errors
=> [#<ZeroDivisionError: divided by 0>]
```

It is worth mention that a failed proc will return `nil`.

## Testing
If you are using RSpec, you will notice that it might not play well with threads. ActiveRecord opens a database connection for every thread and since RSpec tests are wrapped in a transaction, by the time your promise tries to access something on the database, for example, a user, gems like Database Cleaner probably already triggered and deleted the user, resulting in `ActiveRecord::RecordNotFound` errors. You have a couple of solutions like disable transactional fixtures if you are using it or update the Database Cleaner strategy (that will result in much slower tests).
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

You can also set the stragegy globally using `ConcurrentRails::Testing.fake!` or `ConcurrentRails::Testing.immediate!`

## Further reading

For more information on how Futures work and how Rails handle multithread check these links:

[Future documentation](https://github.com/ruby-concurrency/concurrent-ruby/blob/master/docs-source/future.md)

[Threading and code execution on rails](https://guides.rubyonrails.org/threading_and_code_execution.html)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'concurrent_rails', '~> 0.2.1'
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

Pull-requests are always welcome

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
