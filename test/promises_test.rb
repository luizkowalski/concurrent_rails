# frozen_string_literal: true

require 'test_helper'

class PromisesTest < ActiveSupport::TestCase
  test 'should retrun value as expected' do
    future = ConcurrentRails::Promises.future { 42 }

    assert(future.value, 42)
  end

  test 'should chain futures with `then`' do
    future = ConcurrentRails::Promises.future { 42 }.then { |v| v * 2 }

    assert(future.value, 84)
  end

  test 'should chain futures with `then` and args' do
    future = ConcurrentRails::Promises.future { 42 }.
             then(4) { |v, args| (v * 2) - args }

    assert(future.value, 80)
  end
end
