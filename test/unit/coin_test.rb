require File.dirname(__FILE__) + '/../unit_test_helper'
require 'coin'

class CoinTest < Test::Unit::TestCase
  def setup
    @josua = User.create('email' => 'sender@renuo.ch', 'name' => 'Josue')
    @josuette = User.create('email' => 'receiver@renuo.ch', 'name' => 'Josuette')
  end

  def test_all_good
    coin = Coin.new('sender' => @josua, 'receiver' => @josuette, 'message' => 'LOL, nice!')
    assert coin.valid?
  end

  def test_presence_validation
    coin = Coin.new
    assert !coin.valid?
    assert coin.errors.on('sender_id').to_s.include?('empty')
    assert coin.errors.on('receiver_id').to_s.include?('empty')
    assert coin.errors.on('message').to_s.include?('empty')
  end

  def test_receiver_is_not_sender
    coin = Coin.new('sender' => @josua, 'receiver' => @josua, 'message' => 'LOL, nice!')
    assert !coin.valid?
    assert coin.errors.on('receiver_id').to_s.include?('is sender')
  end
end
