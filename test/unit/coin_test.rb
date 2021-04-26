require File.dirname(__FILE__) + '/../unit_test_helper'
require 'coin'

class CoinTest < Test::Unit::TestCase
  def setup
    @coins = create_fixtures "coins"
  end

  def test_something
    assert true, "Test implementation missing"
  end
end
