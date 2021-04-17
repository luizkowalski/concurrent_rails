# frozen_string_literal: true

require 'test_helper'

class AppTest < ActiveSupport::TestCase
  test 'works with Rails' do
    response = DummyService.do_something

    assert_equal(response, 42)
  end
end
