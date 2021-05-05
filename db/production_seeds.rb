require File.dirname(__FILE__) + '/../vendor/railties/load_path'
require 'active_record'
require 'yaml'

require 'user'
require 'coin'

db_conf = YAML::load(File.open('config/database.yml'))
ActiveRecord::Base.establish_connection(db_conf['production'])

josua = User.create('email' => 'josua.schmid@renuo.ch', 'name' => 'Josua Schmid')
ale = User.create('email' => 'alessandro.rodi@renuo.ch', 'name' => 'Alessandro Rodi')

Coin.create('sender_id' => josua.id, 'receiver_id' => ale.id, 'message' => 'Nice job with Cancancan!')
Coin.create('sender_id' => ale.id, 'receiver_id' => josua.id, 'message' => 'Nice job with Gifcoins!')
