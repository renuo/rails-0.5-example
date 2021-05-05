require 'application_controller'
require 'user'
require 'user_helper'

class UserController < ApplicationController
  include UserHelper

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      logger.info url_for(:action => 'login', :path_params => {'login_token' => @user.login_token}) # TODO replace with an actual email
      flash["notice"] = "Succesfully created user"
      render_action :create
    else
      flash["notice"] = "Validation failed"
      render_action :new
    end
  end

  def login
    @user = User.find_first(["login_token = '%s'", params['login_token']])
    if @user
      @session['user_id'] = @user.id
      flash["notice"] = "Succesfully logged in"
      redirect_to :controller => 'coin', :action => 'mine', :path_params => {}
    else
      flash["notice"] = "Session expired or never existed" # TODO a
      redirect_to :action => 'new', :path_params => {}
    end
  end

  def logout
    close_session
  end

  private

  def user_params
    extract_params @params['user'], ['email', 'name']
  end
end
