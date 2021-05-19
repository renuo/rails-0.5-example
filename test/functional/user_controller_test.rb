require File.dirname(__FILE__) + '/../functional_test_helper'
require 'user_controller'

# Raise errors beyond the default web-based presentation
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase
  def setup
    @request = ActionController::TestRequest.new
    @request.host = ""
  end

  def test_new
    @request.action = "new"
    assert_equal "user/new", UserController.process_test(@request).template.first_render
  end

  def test_create_success
    @request.action = "create"
    @request.request_parameters['user'] = { 'email' => 'creator@renuo.ch', 'name' => 'Josua'}
    assert_equal "user/create", UserController.process_test(@request).template.first_render
  end

  def test_create_failure
    @request.action = "create"
    @request.request_parameters['user'] = { 'email' => '', 'name' => ''}
    assert_equal "user/new", UserController.process_test(@request).template.first_render
  end

  def test_login_success
    user = User.create('email' => 'login@renuo.ch', 'name' => 'Loginer')
    @request.action = "login"
    @request.query_parameters['otp'] = user.login_token
    assert_equal user.id, UserController.process_test(@request).session["user_id"]
  end

  def test_login_failure
    @request.action = "login"
    @request.query_parameters['otp'] = 'blub'
    assert_nil UserController.process_test(@request).session["user_id"]
  end

  def test_logout
    @request.action = "logout"
    assert_nil UserController.process_test(@request).session["user_id"]
  end
end
