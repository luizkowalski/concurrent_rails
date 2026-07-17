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

  test "real? returns true after a scoped mode block raises" do
    assert_raises(RuntimeError) do
      ConcurrentRails::Testing.immediate { raise "boom" }
    end

    assert_predicate(ConcurrentRails::Testing, :real?)
  end

  test "immediate applies to `delay`" do
    result = ConcurrentRails::Testing.immediate do
      ConcurrentRails::Promises.delay { 42 }
    end

    assert_equal(:immediate, result.executor)
    assert_equal(42, result.value)
  end

  test "fake applies to `delay`" do
    result = ConcurrentRails::Testing.fake do
      ConcurrentRails::Promises.delay { 42 }
    end

    assert_equal(42, result)
  end

  test "fake applies to `schedule`" do
    result = ConcurrentRails::Testing.fake do
      ConcurrentRails::Promises.schedule(60) { 42 }
    end

    assert_equal(42, result)
  end

  test "immediate! sets the default mode until reset" do
    ConcurrentRails::Testing.immediate!
    result = ConcurrentRails::Promises.future { 42 }

    assert_equal(:immediate, result.executor)
  ensure
    ConcurrentRails::Testing.real!
  end
end
