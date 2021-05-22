require File.dirname(__FILE__) + '/../functional_test_helper'
require 'user_controller'

# Raise errors beyond the default web-based presentation
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < Test::Unit::TestCase
  def setup
    @request = ActionController::TestRequest.new
    @request.host = ""
  end

  def test_start
    @request.action = "start"
    assert_equal "user/start", UserController.process_test(@request).template.first_render
  end

  def test_find_success
    user = User.create('email' => 'existing@renuo.ch')
    old_user_count = User.count
    @request.action = "find_or_create"
    @request.request_parameters['user'] = { 'email' => user.email }
    assert_equal "user/find_or_create", UserController.process_test(@request).template.first_render
    assert_equal old_user_count, User.count
  end

  def test_create_success
    old_user_count = User.count
    @request.action = "find_or_create"
    @request.request_parameters['user'] = { 'email' => 'new@renuo.ch' }
    assert_equal "user/find_or_create", UserController.process_test(@request).template.first_render
    assert_equal old_user_count + 1, User.count
  end

  def test_create_failure
    @request.action = "find_or_create"
    @request.request_parameters['user'] = { 'email' => '' }
    assert_equal "user/start", UserController.process_test(@request).template.first_render
  end

  def test_login_success
    user = User.create('email' => 'login@renuo.ch', 'name' => 'Loginer')
    @request.action = "login"
    @request.query_parameters['otp'] = user.login_token
    assert_equal user.id, UserController.process_test(@request).session["user_id"]
  end

  def test_login_success_redirect
    @request.action = "login"

    # When user has name
    user = User.create('email' => 'login-redirect1@renuo.ch', 'name' => 'Loginer')
    @request.query_parameters['otp'] = user.login_token
    headers = UserController.process_test(@request).headers
    assert headers['Status'][/^302/] # redirect
    assert headers['location'][/coin\/mine/]

    # When user name is not set
    user = User.create('email' => 'login-redirect2@renuo.ch')
    @request.query_parameters['otp'] = user.login_token
    headers = UserController.process_test(@request).headers
    assert headers['Status'][/^302/] # redirect
    assert headers['location'][/user\/edit/]
  end

  def test_login_failure
    user = User.create('email' => 'protected@renuo.ch')
    @request.action = "login"

    # No token
    assert_nil UserController.process_test(@request).session["user_id"]

    # Token too short
    @request.query_parameters['otp'] = 'blub'
    assert_nil UserController.process_test(@request).session["user_id"]

    # Token has correct format but no user
    @request.query_parameters['otp'] = User.generate_login_token
    assert_nil UserController.process_test(@request).session["user_id"]

    # When trying to login again, but with wrong token: no logout
    @request.session["user_id"] = user.id
    @request.query_parameters['otp'] = User.generate_login_token
    assert_equal user.id, UserController.process_test(@request).session["user_id"]
  end

  def test_logout
    user = User.create('email' => 'logout@renuo.ch')
    @request.action = "logout"

    # If user is NOT logged in
    @request.session["user_id"] = nil
    assert_nil UserController.process_test(@request).session["user_id"]

    # If user is logged in
    @request.session["user_id"] = user.id
    assert_nil UserController.process_test(@request).session["user_id"]
  end

  def test_edit_success
    user = User.create('email' => 'edit-success@renuo.ch')
    @request.action = "edit"
    @request.session["user_id"] = user.id
    assert_equal "user/edit", UserController.process_test(@request).template.first_render
  end

  def test_edit_failure
    User.create('email' => 'edit-failure@renuo.ch')
    @request.action = "edit"

    # Without login
    @request.session["user_id"] = nil
    headers = UserController.process_test(@request).headers
    assert headers['Status'][/^302/] # redirect
    assert headers['location'][/user\/start/]
  end

  def test_update_success
    user = User.create('email' => 'update-success@renuo.ch')
    @request.action = "update"
    @request.request_parameters['user'] = { 'name' => user.email }
    @request.session["user_id"] = user.id
    headers = UserController.process_test(@request).headers
    assert headers['Status'][/^302/] # redirect
    assert headers['location'][/coin\/mine/]
  end

  def test_update_failure
    user = User.create('email' => 'update-failure@renuo.ch')
    @request.action = "update"
    @request.request_parameters['user'] = { 'name' => '' }

    # Without login
    @request.session["user_id"] = nil
    headers = UserController.process_test(@request).headers
    assert headers['Status'][/^302/] # redirect
    assert headers['location'][/user\/start/]

    # With login
    @request.session["user_id"] = user.id
    assert_equal "user/edit", UserController.process_test(@request).template.first_render
  end
end
