require File.dirname(__FILE__) + '/../functional_test_helper'
require 'application_controller'

class ApplicationController
  def rescue_action(e) raise e end
end

class ApplicationControllerTest < Test::Unit::TestCase
  def setup
    @request = ActionController::TestRequest.new
    @request.host = ""
    @request.action = "test"
  end

  class TestExtractParamsController < ApplicationController
    def test
      @extracted = extract_params @params['user'], ['email']
      render_text ''
    end
  end
  def test_extract_params
    @request.request_parameters['user'] = { 'email' => 'josua@hey.com', 'name' => 'Josua'}
    assert_equal({ 'email' => "josua@hey.com" }, TestExtractParamsController.process_test(@request).template.assigns['extracted'])
  end

  class TestCurrentUserController < ApplicationController
    def test
      @user = current_user
      render_text ''
    end
  end
  def test_current_user_fail
    User.create('email' => 'josua+fail@hey.com', 'name' => 'josua')
    @request.session['user_id'] = nil
    assert_nil TestCurrentUserController.process_test(@request).template.assigns['user']
  end
  def test_current_user_success
    user = User.create('email' => 'josua+success@hey.com', 'name' => 'josua')
    @request.session['user_id'] = user.id
    assert_equal user, TestCurrentUserController.process_test(@request).template.assigns['user']
  end

  class TestAuthorizeUserController < ApplicationController
    before_filter :authorize_user!

    def test
      render_text 'passed'
    end
  end
  def test_authorize_user_fail
    assert TestAuthorizeUserController.process_test(@request).headers['Status'][/^302/] # redirect
  end
  def test_authorize_user_from_current_user
    user = User.create('email' => 'loggedin@hey.com', 'name' => 'josua')
    @request.session['user_id'] = user.id
    assert_equal 'passed', TestAuthorizeUserController.process_test(@request).body
  end
  def test_authorize_user_from_params
    user = User.create('email' => 'loggingin@hey.com', 'name' => 'josua')
    @request.query_parameters['otp'] = user.login_token
    assert_equal 'passed', TestAuthorizeUserController.process_test(@request).body
  end
end
