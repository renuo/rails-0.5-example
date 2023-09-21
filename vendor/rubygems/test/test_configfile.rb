#!/usr/bin/env ruby

require 'test/unit'
require 'rubygems/config_file'

class TestArgPreprocessor < Test::Unit::TestCase
  def setup
  end

  def test_create
    @cfg = Gem::ConfigFile.new([])
    assert ! @cfg.backtrace
    assert_equal File.join(ENV['HOME'], '.gemrc'), @cfg.config_file_name
  end

  def test_backtrace
    args = %w(--this --that --backtrace --other stuff)
    @cfg = Gem::ConfigFile.new(args)
    assert @cfg.backtrace
    assert_equal %w(--this --that --other stuff), @cfg.args
  end

  def test_config_file
    args = %w(--this --that --config-file test/testgem.rc --other stuff)
    @cfg = Gem::ConfigFile.new(args)
    assert_equal 'test/testgem.rc', @cfg.config_file_name
    assert_equal %w(--this --that --other stuff), @cfg.args
  end

  def test_config_file2
    args = %w(--this --that --config-file=test/testgem.rc --other stuff)
    @cfg = Gem::ConfigFile.new(args)
    assert_equal 'test/testgem.rc', @cfg.config_file_name
    assert_equal %w(--this --that --other stuff), @cfg.args
  end
end
