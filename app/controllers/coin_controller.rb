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
    sender = current_user
    @receiver = User.find_or_create(receiver_params["email"])
    @coin = Coin.new(coin_params.merge("sender" => sender, "receiver" => @receiver))

    # Antecedent deduction (prepaid race conditions for hacker)
    User.update_all('budget = budget - 1', ['id = %d', sender.id])

    if sender.budget >= 0 && @receiver.valid? && @coin.save
      flash["notice"] = "A gifcoin was sent to #{@receiver.name || @receiver.email}"
      redirect_to :controller => 'coin', :action => "mine"
    else
      User.update_all('budget = budget + 1', ['id = %d', sender.id])
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
end
