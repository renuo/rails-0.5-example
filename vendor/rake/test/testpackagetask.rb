#!/usr/bin/env ruby

require 'test/unit'
require 'rake/packagetask'

class TestPackageTask < Test::Unit::TestCase
  def test_create
    pkg = Rake::PackageTask.new("pkgr", "1.2.3") { |p|
      p.package_files << "install.rb"
      p.package_files.include(
	'[A-Z]*',
	'bin/**/*',
	'lib/**/*.rb',
	'test/**/*.rb',
	'doc/**/*',
	'build/rubyapp.rb',
	'*.blurb')
      p.package_files.exclude(/\bCVS\b/)
      p.package_files.exclude(/~$/)
      p.package_dir = 'pkg'
      p.need_tar = true
      p.need_zip = true
    }
    assert_equal "pkg", pkg.package_dir
    assert pkg.package_files.include?("bin/rake")
    assert "pkgr", pkg.name
    assert "1.2.3", pkg.version
    assert Task[:package]
    assert Task['pkg/pkgr-1.2.3.tgz']
    assert Task['pkg/pkgr-1.2.3.zip']
    assert Task["pkg/pkgr-1.2.3"]
    assert Task[:clobber_package]
    assert Task[:repackage]
  end

  def test_missing_version
    assert_raises(RuntimeError) {
      pkg = Rake::PackageTask.new("pkgr") { |p| }
    }
  end

  def test_no_version
    pkg = Rake::PackageTask.new("pkgr", :noversion) { |p| }
    assert "pkgr", pkg.send(:package_name)
  end

  def test_clone
    pkg = Rake::PackageTask.new("x", :noversion)
    p2 = pkg.clone
    pkg.package_files << "y"
    p2.package_files << "x"
    assert_equal ["y"], pkg.package_files
    assert_equal ["x"], p2.package_files
  end
end


begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
  puts "WARNING: RubyGems not installed"
end

if ! defined?(Gem)
  puts "WARNING: Unable to test GemPackaging ... requires RubyGems"
else
  class TestGemPackageTask < Test::Unit::TestCase
    def test_gem_package
      gem = Gem::Specification.new do |g|
	g.name = "pkgr"
	g.version = "1.2.3"
	g.files = FileList["x"].resolve
      end
      pkg = Rake::GemPackageTask.new(gem)  do |p|
	p.package_files << "y"
      end
      assert_equal ["x", "y"], pkg.package_files
    end
  end
end
