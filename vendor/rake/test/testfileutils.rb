#!/usr/bin/env ruby

require 'rake'
require 'test/unit'
require 'test/filecreation'
require 'fileutils'

class TestFileUtils < Test::Unit::TestCase
  include FileCreation

  def test_rm_one_file
    create_file("testdata/a")
    FileUtils.rm_r "testdata/a"
    assert ! File.exist?("testdata/a")
  end

  def test_rm_two_files
    create_file("testdata/a")
    create_file("testdata/b")
    FileUtils.rm_r ["testdata/a", "testdata/b"]
    assert ! File.exist?("testdata/a")
    assert ! File.exist?("testdata/b")
  end

  def test_rm_filelist
    list = Rake::FileList.new << "testdata/a" << "testdata/b"
    list.each { |fn| create_file(fn) }
    FileUtils.rm_r list
    assert ! File.exist?("testdata/a")
    assert ! File.exist?("testdata/b")
  end

  def test_verbose
    verbose true
    assert_equal true, verbose
    verbose false
    assert_equal false, verbose
    verbose(true){
      assert_equal true, verbose
    }
    assert_equal false, verbose
  end

  def test_nowrite
    nowrite true
    assert_equal true, nowrite
    nowrite false
    assert_equal false, nowrite
    nowrite(true){
      assert_equal true, nowrite
    }
    assert_equal false, nowrite
  end

  def test_sh
    verbose(false) { sh %{test/shellcommand.rb} }
    assert true, "should not fail"
  end

  def test_sh_multiple_arguments
    ENV['RAKE_TEST_SH'] = 'someval'
    # This one gets expanded by the shell
    verbose(false) { sh %{test $RAKE_TEST_SH = someval} }
    assert true, "should not fail"
    assert_raises(RuntimeError) {
      # This one does not get expanded
      verbose(false) { sh 'test','$RAKE_TEST_SH', '=', 'someval' }
    }
  end

  def test_sh_failure
    assert_raises(RuntimeError) { 
      verbose(false) { sh %{test/shellcommand.rb 1} }
    }
  end

  def test_sh_special_handling
    count = 0
    verbose(false) {
      sh(%{test/shellcommand.rb}) do |ok, res|
	assert(ok)
	assert_equal 0, res.exitstatus
	count += 1
      end
      sh(%{test/shellcommand.rb 1}) do |ok, res|
	assert(!ok)
	assert_equal 1, res.exitstatus
	count += 1
      end
    }
    assert_equal 2, count, "Block count should be 2"
  end

  def test_ruby
    verbose(false) do
      ENV['RAKE_TEST_RUBY'] = "123"
      block_run = false
      # This one gets expanded by the shell
      ruby %{-e "exit $RAKE_TEST_RUBY"} do |ok, status|
        assert(!ok)
        assert_equal 123, status.exitstatus
	block_run = true
      end
      assert block_run, "The block must be run"

      # This one does not get expanded
      block_run = false
      ruby '-e', 'exit "$RAKE_TEST_RUBY".length' do |ok, status|
        assert(!ok)
        assert_equal 15, status.exitstatus
	block_run = true
      end
      assert block_run, "The block must be run"
    end
  end

end
