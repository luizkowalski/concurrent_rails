# frozen_string_literal: true

require "test_helper"

class RactorCompatibilityTest < ActiveSupport::TestCase
  test "scoped fake mode executes a promise inside a secondary Ractor" do
    ractor = Ractor.new do
      ConcurrentRails::Testing.fake do
        ConcurrentRails::Promises.future { 42 }
      end
    end

    assert_equal(42, ractor_result(ractor))
  end

  test "bang mode defaults are isolated between Ractors" do
    ractor = Ractor.new do
      ConcurrentRails::Testing.immediate!

      ConcurrentRails::Testing.execution_mode
    end

    assert_equal("immediate", ractor_result(ractor))
    assert_predicate(ConcurrentRails::Testing, :real?)
  end

  private

  def ractor_result(ractor)
    ractor.respond_to?(:value) ? ractor.value : ractor.take
  end
end
