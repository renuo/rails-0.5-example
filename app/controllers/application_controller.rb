require 'action_controller'
require 'user'

class ApplicationController < ActionController::Base
  layout 'layouts/application'

  private

  def extract_params(hash, keys)
    return {} unless hash
    Hash[*hash.select {|key, _value| keys.include?(key) }.flatten]
  end

  def current_user
    User.find_first(["id = %d", @session['user_id']]) if @session['user_id']
  end

  def authorize_user!
    return true if current_user

    user = User.find_first(["login_token = '%s'", params['login_token']])
    if user
      @session['user_id'] = user.id
      return true
    end

    redirect_to :controller => 'user', :action => 'new' unless current_user
  end
end
