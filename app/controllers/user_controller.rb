require "application_controller"
require "user"

class UserController < ApplicationController
  def start
    @user = User.new
  end

  def find_or_create
    @user = User.find_or_create(user_params['email'])
    if @user.valid?
      logger.info url_for(:action => "login", :params => {"otp" => @user.login_token}) # TODO: replace with an actual email and use path_params
    else
      flash["notice"] = "Validation failed"
      render_action :start
    end
  end

  def login
    if login_by_otp
      flash["notice"] = "Succesfully logged in"
      if current_user.name
        redirect_to :controller => "coin", :action => "mine"
      else
        redirect_to :controller => "user", :action => "edit"
      end
    else
      flash["notice"] = "Session expired or never existed"
      redirect_to :action => "start"
    end
  end

  def logout
    if current_user
      current_user.update_attribute("login_token", User.generate_login_token) # Reset OTP
      @session["user_id"] = nil # TODO: delete session instead
    end
  end

  def edit
    authorize_user! or return
    @user = current_user
  end

  def update
    authorize_user! or return
    @user = current_user

    if user_params['name'] && user_params['name'].length > 0
      @user.update_attribute('name', user_params['name'])
      flash["notice"] = "What a nice name!"
      redirect_to :controller => "coin", :action => "mine"
    else
      flash["notice"] = "Life is not a pony yard"
      render_action :edit
    end
  end

  private

  def user_params
    extract_params params["user"], ["email", "name"]
  end
end
