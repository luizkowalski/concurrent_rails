# frozen_string_literal: true

require "test_helper"

class ImmediateAdapterTest < ActiveSupport::TestCase
  test "should override :io executor when using `immediate`" do
    result = ConcurrentRails::Testing.immediate do
      ConcurrentRails::Promises.future { 42 }
    end

    assert_equal(:immediate, result.executor)
    assert_instance_of(ConcurrentRails::Promises, result)
  end

  test "should not return a promise when using `fake`" do
    result = ConcurrentRails::Testing.fake do
      ConcurrentRails::Promises.future { 42 }
    end

    assert_equal(42, result)
    assert_instance_of(Integer, result)
  end

  test "real? returns true after a scoped mode block exits" do
    ConcurrentRails::Testing.immediate { ConcurrentRails::Promises.future { 42 } }

    assert_predicate(ConcurrentRails::Testing, :real?)
  end
end
