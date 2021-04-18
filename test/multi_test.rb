# frozen_string_literal: true

require 'test_helper'

class MultiTest < ActiveSupport::TestCase
  test 'should only accepts Procs' do
    assert_raises(ArgumentError) { ConcurrentRails::Multi.enqueue(42) }
  end

  test 'multiple actions without errors' do
    multi = ConcurrentRails::Multi.enqueue(
      -> { 42 },
      -> { :multi_test }
    )

    assert_equal(multi.compute, [42, :multi_test])
    assert(multi.complete?)
    assert_empty(multi.errors)
  end

  test 'multiple actions with errors' do
    multi = ConcurrentRails::Multi.enqueue(
      -> { 42 },
      -> { 2 / 0 }
    )

    assert_equal(multi.compute, [42, nil])
    assert(multi.complete?)
    assert_not_empty(multi.errors)
  end

  test 'multiple actions with executor' do
    pool = ::Concurrent::CachedThreadPool.new
    multi = ConcurrentRails::Multi.enqueue(
      -> { 42 },
      -> { :multi_test },
      executor: pool
    )

    assert_equal(multi.compute, [42, :multi_test])
    assert(multi.complete?)
  end
end
