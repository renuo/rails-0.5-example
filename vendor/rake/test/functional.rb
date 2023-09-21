#!/usr/bin/env ruby

begin
  require 'rubygems'
  require_gem 'session'
rescue LoadError
  puts "UNABLE TO RUN FUNCTIONAL TESTS"
  puts "No Session Found"
end

require 'test/unit'
require 'fileutils'

class FunctionalTest < Test::Unit::TestCase
  def setup
    @rake_path = File.expand_path("bin/rake")
    lib_path = File.expand_path("lib")
    @ruby_options = "-I#{lib_path} -I."
    @verbose = true if ENV['VERBOSE']
  end

  def test_rake_default
    Dir.chdir("test/data/default") do rake end
    assert_match /^DEFAULT$/, @out
    assert_status
  end

  def test_rake_error_on_bad_task
    Dir.chdir("test/data/default") do rake "xyz" end
    assert_match /rake aborted/, @out
    assert_status(1)
  end

  def test_env_availabe_at_top_scope
    Dir.chdir("test/data/default") do rake "TESTTOPSCOPE=1" end
    assert_match /^TOPSCOPE$/, @out
    assert_status
  end

  def test_env_availabe_at_task_scope
    Dir.chdir("test/data/default") do rake "TESTTASKSCOPE=1 task_scope" end
    assert_match /^TASKSCOPE$/, @out
    assert_status
  end

  def test_multi_desc
    Dir.chdir("test/data/multidesc") do rake "-T" end
    assert_match %r{^rake a *# A / A2 *$}, @out
    assert_match %r{^rake b *# B *$}, @out
    assert_no_match %r{^rake c}, @out
  end

  def test_rbext
    Dir.chdir("test/data/rbext") do rake "-N" end
    assert_match %r{^OK$}, @out
  end

  def test_nosearch
    Dir.chdir("test/data/nosearch") do rake "-N" end
    assert_match %r{^No Rakefile found}, @out
  end

  def test_dry_run
    Dir.chdir("test/data/default") do rake "-n", "other" end
    assert_match %r{Execute \(dry run\) default}, @out
    assert_match %r{Execute \(dry run\) other}, @out
    assert_no_match %r{DEFAULT}, @out
    assert_no_match %r{OTHER}, @out
  end

  private

  def rake(*option_list)
    options = option_list.join(' ')
    shell = Session::Shell.new
    command = "ruby #{@ruby_options} #{@rake_path} #{options}"
    puts "COMMAND: [#{command}]" if @verbose
    @out, @err = shell.execute command
    @status = shell.exit_status
    puts "STATUS:  [#{@status}]" if @verbose
    puts "OUTPUT:  [#{@out}]" if @verbose
    puts "ERROR:   [#{@err}]" if @verbose
    puts "PWD:     [#{Dir.pwd}]" if @verbose
    shell.close
  end

  def assert_status(expected_status=0)
    assert_equal expected_status, @status
  end

end
