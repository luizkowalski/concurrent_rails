# frozen_string_literal: true

require 'test_helper'

class FutureTest < ActiveSupport::TestCase
  test 'should be a :pending future' do
    future = ConcurrentRails::Future.new do
      sleep(5)
      42
    end.execute

    assert_equal(future.state, :pending)
  end

  test 'should be a :rejected future' do
    future = ConcurrentRails::Future.new do
      2 / 0
    end.execute

    assert_nil(future.value)
    assert_equal(future.state, :rejected)
    assert_instance_of(ZeroDivisionError, future.reason)
  end

  test 'should be a :fulfilled future' do
    future = ConcurrentRails::Future.new do
      42
    end.execute

    assert_equal(future.value, 42)
    assert_equal(future.state, :fulfilled)
  end

  test 'should execute with a different pool' do
    pool = ::Concurrent::CachedThreadPool.new
    future = ConcurrentRails::Future.new(executor: pool) do
      42
    end.execute

    assert_equal(future.value, 42)
    assert_equal(future.state, :fulfilled)
  end
end
