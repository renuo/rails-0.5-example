# $GEM_PATH ||= []
# $GEM_PATH.unshift(File.join(File.dirname(File.expand_path(__FILE__)), "mock", "gems"))
require 'rubygems'
Gem::manage_gems
Gem.use_paths("test/mock/gems")
