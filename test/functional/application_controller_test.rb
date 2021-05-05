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
  def test_current_user
    user = User.create('email' => 'josua@hey.com', 'name' => 'Josua')
    assert_not_nil user.id

    @request.session['user_id'] = nil
    assert_nil TestCurrentUserController.process_test(@request).template.assigns['user']

    @request.session['user_id'] = user.id
    assert_equal user, TestCurrentUserController.process_test(@request).template.assigns['user']
  end
end
