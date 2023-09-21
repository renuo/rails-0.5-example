require "application_controller"
require "coin_helper"
require "coin"

class CoinController < ApplicationController
  include CoinHelper

  class TransactionException < Exception
  end

  before_filter :authorize_user!

  def list
    @coins = current_user.given_coins + current_user.received_coins
  end

  def mine
    @coin = Coin.new
    @receiver = User.new
  end

  def create
    sender = current_user
    @receiver = User.find_or_create(receiver_params["email"])
    @coin = Coin.new(coin_params.merge("sender" => sender, "receiver" => @receiver))

    ActiveRecord::Base.transaction(sender, @coin) do
      if sender.budget > 0 && @receiver.valid?
        User.update_all("budget = budget - 1", ["id = %d", sender.id])
        @coin.save

        raise TransactionException if User.find_first(["id = %d AND budget < 0", sender.id]) || !@coin.id?
      end
    end

    flash["notice"] = "A gifcoin was sent to #{@receiver.name || @receiver.email}"
    redirect_to :controller => 'coin', :action => "mine"

  rescue TransactionException
    flash["notice"] = "Validation failed"
    render_action :mine
  end

  private

  def receiver_params
    extract_params params["receiver"], ["email"]
  end

  def coin_params
    extract_params params["coin"], ["message"]
  end
end
