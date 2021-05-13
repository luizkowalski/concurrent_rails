# frozen_string_literal: true

require 'test_helper'

class DelayTest < ActiveSupport::TestCase
  test 'should be pending until touched' do
    delay_untouched = ConcurrentRails::Promises.delay { 42 }

    assert_equal(:pending, delay_untouched.state)
  end

  test 'should run when touched' do
    touched_delay = ConcurrentRails::Promises.delay { 42 }
    assert_equal(:pending, touched_delay.state)

    touched_delay.touch
    assert_equal(42, touched_delay.value)
  end

  test 'should execute on_fulfillment callback' do
    test_user = User.create(name: 'old name') # Create an user

    delay = ConcurrentRails::Promises.delay { User.last }.
            on_fulfillment! { |user| user.update!(name: 'new name') }

    assert_equal('old name', test_user.name) # Promise was not triggered yet

    delay.value

    assert_equal('new name', test_user.reload.name)
  end

  test 'should execute on_rejection callback' do
    array = Concurrent::Array.new
    delay = ConcurrentRails::Promises.delay { 2 / 0 }.
            on_rejection! { |reason| array.push("Error: #{reason}") }

    delay.value

    assert_not_empty(array)
    assert_equal('Error: divided by 0', array.pop)
  end

  test 'should not execute on_rejection callback when successful' do
    successful_array = Concurrent::Array.new
    failed_array     = Concurrent::Array.new

    delay = ConcurrentRails::Promises.delay { 42 }.
            on_fulfillment! { |v| successful_array.push(v) }.
            on_rejection!   { |v| failed_array.push(v) }

    delay.value

    assert_not_empty(successful_array)
    assert_empty(failed_array)
  end

  test 'should chain the operation with callbacks' do
    array = Concurrent::Array.new
    delay = ConcurrentRails::Promises.delay { 42 }.
            then { |v| v * 2 }.
            on_fulfillment! { |v| array.push(v) }

    delay.value

    assert_equal(84, array.pop)
  end

  test 'should execute callback on_resolution' do
    array = Concurrent::Array.new
    delay = ConcurrentRails::Promises.delay { 42 }.
            then { |v| v * 2 }.
            on_resolution! { |_fulfilled, value, _reason| array.push(value) }

    delay.value

    assert_equal(84, array.pop)
  end
end
