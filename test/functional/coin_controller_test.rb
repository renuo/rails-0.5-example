require File.dirname(__FILE__) + '/../functional_test_helper'
require 'coin_controller'

# Raise errors beyond the default web-based presentation
class CoinController; def rescue_action(e) raise e end; end

class CoinControllerTest < Test::Unit::TestCase
  def setup
    @request = ActionController::TestRequest.new
    @request.host = ""
  end

  # def test_index
  #   @request.action = "index"
  #   assert_equal "coin/index", CoinController.process_test(@request).template.first_render
  # end

  def test_truth
    assert true, "Test implementation missing"
  end
end
