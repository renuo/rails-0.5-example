require "active_record"
require "user"

class Coin < ActiveRecord::Base
  belongs_to :sender, :class_name => "User", :foreign_key => "sender_id"
  belongs_to :receiver, :class_name => "User", :foreign_key => "receiver_id"

  def validate
    errors.add_on_empty %w(sender_id receiver_id message)
    errors.add("receiver_id", "is sender") if receiver_id == sender_id
  end
end
