# frozen_string_literal: true

require "test_helper"

class ScheduleTest < ActiveSupport::TestCase
  test "should be pending until the scheduled time" do
    scheduled = ConcurrentRails::Promises.schedule(0.5) { 42 }

    assert_equal(:pending, scheduled.state)
  end

  test "should execute after the given delay" do
    scheduled = ConcurrentRails::Promises.schedule(0.01) { 42 }

    assert_equal(42, scheduled.value)
  end

  test "should accept arguments" do
    scheduled = ConcurrentRails::Promises.schedule(0.01, 6) { |v| v * 7 }

    assert_equal(42, scheduled.value)
  end
end
