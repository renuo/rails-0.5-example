require "application_controller"
require "coin_helper"
require "coin"

class CoinController < ApplicationController
  include CoinHelper

  before_filter :authorize_user!

  def list
    @coins = Coin.find_all
  end

  def mine
    @coin = Coin.new
    @receiver = User.new
  end

  def create
    @receiver = find_or_create_by(receiver_params["email"])
    @coin = Coin.new(coin_params.merge("sender" => current_user, "receiver" => @receiver))

    if @receiver.valid? && @coin.save
      flash["notice"] = "Coin sent"
      render_action :create
    else
      flash["notice"] = "Validation failed"
      render_action :mine
    end
  end

  private

  def receiver_params
    extract_params params["receiver"], ["email"]
  end

  def coin_params
    extract_params params["coin"], ["message"]
  end

  def find_or_create_by(email)
    User.find_first(["email = '%s'", email]) || User.create("email" => email)
  end
end
