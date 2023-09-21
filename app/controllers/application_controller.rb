require "action_controller"
require "user"

class ApplicationController < ActionController::Base
  layout "layouts/application"

  # Make controller helpers available to view templates
  template_class.class_eval do
    def current_user
      controller.send(:current_user)
    end
  end

  private

  def extract_params(hash, keys)
    return {} unless hash
    Hash[*hash.select {|key, _value| keys.include?(key) }.flatten]
  end

  def local_request? #:doc:
    super || @request.remote_addr[0..6] == "172.17."
  end

  def current_user
    if @session["user_id"]
      User.find_first(["id = %d", @session["user_id"]]) # TODO: caching?
    end
  end

  def authorize_user!
    return true if current_user || login_by_otp # We bypass the login page if an OTP is presented

    flash["notice"] = "Login required"
    redirect_to(:controller => "user", :action => "start") and false
  end

  def login_by_otp
    if params["otp"] && params["otp"].length == 40
      user = User.find_first(["login_token = '%s'", params["otp"]])
      if user
        @session["user_id"] = user.id
        return true
      end
    end
  end
end
