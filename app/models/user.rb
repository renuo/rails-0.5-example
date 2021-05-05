require 'openssl'
require 'active_record'
require 'coin'

class User < ActiveRecord::Base
  has_many :given_coins, :class_name => "Coin", :foreign_key => "sender_id"
  has_many :received_coins, :class_name => "Coin", :foreign_key => "receiver_id"

  attr_accessible :email, :name

  before_validation_on_create :setup_defaults

  private

  def validate
    errors.add_on_empty %w(email)
    errors.add("email", "already taken") if User.count(["email = '%s'", email]) > 0 # exists does not yey exist
    errors.add("email", "has invalid format") unless email =~ /.*@.*\..*/
  end

  def setup_defaults
    self.login_token = OpenSSL::Random.random_bytes(20).unpack('H*').join
    self.budget = 10
  end
end
