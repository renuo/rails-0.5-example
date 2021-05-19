require File.dirname(__FILE__) + '/../functional_test_helper'
require 'coin_controller'

# Raise errors beyond the default web-based presentation
class CoinController; def rescue_action(e) raise e end; end

class CoinControllerTest < Test::Unit::TestCase
  def setup
    @josua = User.create('email' => "josua+#{User.count}@renuo.ch", 'name' => 'Josua')
    @josuette = User.create('email' => "josuette+#{User.count}@renuo.ch", 'name' => 'Josuette')

    @request = ActionController::TestRequest.new
    @request.host = ""
    @request.session['user_id'] = @josua.id
  end

  def test_mine
    @request.action = "mine"
    assert_equal "coin/mine", CoinController.process_test(@request).template.first_render
  end

  def test_create_success
    @request.action = "create"
    @request.request_parameters['receiver'] = { 'email' => @josuette.email}
    @request.request_parameters['coin'] = { 'message' => 'Lol, nice!'}
    assert_equal "coin/create", CoinController.process_test(@request).template.first_render
  end

  def test_create_failure
    @request.action = "create"
    @request.request_parameters['receiver'] = { 'email' => @josua.email} # Receiver is sender
    @request.request_parameters['coin'] = { 'message' => 'Lol, nice!'}
    assert_equal "coin/mine", CoinController.process_test(@request).template.first_render
  end
end
