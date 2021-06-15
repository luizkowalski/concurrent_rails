# Changelog

## 0.2.1

* Added `ConcurrentRails::Testing` tool
* Dropped support for Ruby 2.5
* Added deprecation warning for `ConcurrentRails::Future`
* Wrapped `touch` and `wait` on Rails' executor as well

## 0.2.0

* Added delayed futures
* Added support for callbacks
* Code re-organization

## 0.1.8

* Use the same executor for all `Promises` chaining methods
* Update development dependencies

## 0.1.7

* Added `chain` method to promises
* Fixed wrong method forwarding to `Promises`: `resolved?` instead of `complete?`

## 0.1.6

* Added support for `timeout` and `timeout_value` on `Promises#value`
* Added `future_on` on `Promises`, allowing the user to pass a custom executor
* Default executor for `Future` is now `:fast` instead of `:io`
* Code cleanup

## 0.1.5

* Added `value!` to `ConcurrentRails::Future`
* Updatede development dependencies

## 0.1.4

* Fixed `ConcurrentRails::Promises`'s `future` factory so it handles parameters and blocks correctly

## 0.1.3

* Dropped support for Ruby and Rails versions that reached EOL

## 0.1.2

* Fixed dependencies for development

## 0.1.1

* Hello world
