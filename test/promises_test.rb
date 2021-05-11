# frozen_string_literal: true

require 'test_helper'

class PromisesTest < ActiveSupport::TestCase
  test 'should retrun value as expected' do
    future = ConcurrentRails::Promises.future { 42 }

    assert_equal(42, future.value)
  end

  test 'should retrun `resolved?` with successful operation' do
    future = ConcurrentRails::Promises.future { 42 }
    future.value

    assert(future.resolved?)
  end

  test 'should retrun `resolved?` with failed operation' do
    future = ConcurrentRails::Promises.future { 2 / 0 }
    future.value

    assert(future.resolved?)
  end

  test 'should chain futures with `then`' do
    future = ConcurrentRails::Promises.future { 42 }.then { |v| v * 2 }

    assert_equal(84, future.value)
  end

  test 'should chain futures with `chain`' do
    future = ConcurrentRails::Promises.future { 42 }.chain do |_fulfilled, value, _reason|
      value * 2
    end

    assert_equal(84, future.value)
  end

  test 'should chain futures with `chain` and `then`' do
    future = ConcurrentRails::Promises.future { 42 }.
             chain { |_fulfilled, value, _reason| value * 2 }.
             then { |v| v - 2 }

    assert_equal(82, future.value)
  end

  test 'should chain futures with `then` and args' do
    future = ConcurrentRails::Promises.
             future { 42 }.
             then(4) { |v, args| (v * 2) - args }

    assert_equal(80, future.value)
  end

  test 'should accept `then` argument' do
    future = ConcurrentRails::Promises.
             future { 42 }.
             then(2) { |v, arg| (v * 2) + arg }

    assert_equal(86, future.value!)
  end

  test 'should accept `future` argument' do
    future = ConcurrentRails::Promises.
             future(2) { |v| v * 3 }.
             then { |v| v * 2 }

    assert_equal(12, future.value!)
  end

  test 'should accept `future` and `then` argument' do
    future = ConcurrentRails::Promises.
             future(2) { |v| v * 2 }.
             then(5) { |v, arg| v * arg }

    assert_equal(20, future.value!)
  end

  test 'should return timeout value when future expires' do
    timeout_string = 'timeout'
    value = ConcurrentRails::Promises.future { sleep 0.2 }.
            value(0.1, timeout_string)

    assert_equal(value, timeout_string)
  end
end
