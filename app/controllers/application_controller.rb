require "action_controller"
require "user"

def helper_method(method)
  template_class.class_eval %Q(
    def #{method}(*args, &block)
      controller.send(:'#{method}', *args, &block)
    end
  )
end

class ApplicationController < ActionController::Base
  layout "layouts/application"
  helper_method :current_user

  private

  def extract_params(hash, keys)
    return {} unless hash
    Hash[*hash.select {|key, _value| keys.include?(key) }.flatten]
  end

  def current_user
    if @session["user_id"]
      @_current_user ||= User.find_first(["id = %d", @session["user_id"]])
    end
  end

  def authorize_user!
    return true if current_user

    if params["otp"] && params["otp"].length == 40
      user = User.find_first(["login_token = '%s'", params["otp"]])
      if user
        @session["user_id"] = user.id
        user.update_attribute("login_token", User.generate_login_token)
        return true
      end
    end

    flash["notice"] = "Login required"
    redirect_to(:controller => "user", :action => "new", :path_params => {}) and false
  end
end
