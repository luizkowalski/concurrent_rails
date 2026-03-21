# frozen_string_literal: true

require "test_helper"

class CombinatorTest < ActiveSupport::TestCase
  test "zip resolves when all futures are fulfilled" do
    a = ConcurrentRails::Promises.future { 1 }
    b = ConcurrentRails::Promises.future { 2 }

    result = ConcurrentRails::Promises.zip(a, b).value

    assert_equal([1, 2], result)
  end

  test "any_resolved_future resolves with the first settled future" do
    a = ConcurrentRails::Promises.future { 1 }
    b = ConcurrentRails::Promises.future do
      sleep 1
      2
    end

    result = ConcurrentRails::Promises.any_resolved_future(a, b)
    result.wait

    assert_predicate(result, :resolved?)
  end

  test "fulfilled_future returns an already-fulfilled promise" do
    result = ConcurrentRails::Promises.fulfilled_future(42)

    assert_predicate(result, :fulfilled?)
    assert_equal(42, result.value)
  end

  test "rejected_future returns an already-rejected promise" do
    reason = RuntimeError.new("boom")
    result = ConcurrentRails::Promises.rejected_future(reason)

    assert_predicate(result, :rejected?)
    assert_equal(reason, result.reason)
  end
end
