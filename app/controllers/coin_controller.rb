require 'application_controller'
require 'coin_helper'
require 'coin'

class CoinController < ApplicationController
  include CoinHelper

  before_filter :autorize_user!

  def list
    @coins = Coin.find_all
  end

  def mine
    @coin = Coin.new
  end

  def create
    receiver = User.find_first(["email = '%s'", @params['receiver_email']])
    receiver = User.new('email' => @params['receiver_email']) unless receiver

    Coin.create('receiver' => receiver, 'sender' => current_user, 'message' => @params['message'])
  end
end
