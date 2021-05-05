require File.dirname(__FILE__) + '/../unit_test_helper'
require 'user'

class UserTest < Test::Unit::TestCase
  def test_default_setup
    user = User.create('email' => 'budget@renuo.ch', 'name' => 'J')
    assert_equal 10, user.budget
    assert_equal (20 * 2), user.login_token.length
  end

  def test_presence_validation
    user = User.new('email' => '', 'name' => '')
    assert !user.valid?
    assert user.errors.on('email').to_s.include?('empty')
  end

  def test_email_uniqueness_validation
    User.create('email' => 'josua@renuo.ch', 'name' => 'Josua')
    duplicate_user = User.new('email' => 'josua@renuo.ch', 'name' => 'Josua')
    assert !duplicate_user.valid?
    assert duplicate_user.errors.on('email').to_s.include?('taken')
  end

  def test_email_format_validation
    user = User.new('email' => 'josuarenuoch', 'name' => 'Josua')
    assert !user.valid?
    assert user.errors.on('email').to_s.include?('format')
  end
end
