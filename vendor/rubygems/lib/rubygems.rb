module Kernel

  ##
  # Adds a Ruby Gem to the $LOAD_PATH.  Before a Gem is loaded, its required
  # Gems are loaded (by specified version or highest version).  If the version
  # information is omitted, the highest version Gem of the supplied name is 
  # loaded.  If a Gem is not found that meets the version requirement and/or 
  # a required Gem is not found, a LoadError is raised. More information on 
  # version requirements can be found in the Gem::Version documentation.
  #
  # gem:: [String or Gem::Dependency] The gem name or dependency instance.
  # version_requirement:: [default="> 0.0.0"] The version requirement.
  # return:: [Boolean] true if the Gem is loaded, otherwise false.
  # raises:: [LoadError] if Gem cannot be found or version requirement not met.
  #
  def require_gem(gem, *version_requirements)
    unless version_requirements.size > 0
      version_requirements = ["> 0.0.0"]
    end
    unless gem.respond_to?(:name) && gem.respond_to?(:version_requirements)
      gem = Gem::Dependency.new(gem, version_requirements)
    end
    
    matches = Gem.cache.search(gem.name, gem.version_requirements)
    if matches.size==0
      matches = Gem.cache.search(gem.name)
      if matches.size==0
        raise LoadError.new("\nCould not find RubyGem #{gem.name} (#{gem.version_requirements})\n")
      else
        raise LoadError.new("\nRubyGem version error: #{gem.name}(#{matches.first.version} not #{gem.version_requirements})\n")
      end
    else
      # Get highest matching version
      spec = matches.last
      return false if spec.loaded?
      
      spec.loaded = true
      
      # Load dependent gems first
      spec.dependencies.each do |dep_gem|
        require_gem(dep_gem)
      end
      
      # add bin dir to require_path
      if(spec.bindir) then
        spec.require_paths << spec.bindir
      end

      # Now add the require_paths to the LOAD_PATH
      spec.require_paths.each do |path|
        $:.unshift File.join(spec.full_gem_path, path)
      end
      
      require spec.autorequire if spec.autorequire
      
      return true
    end
  end
end


##
# Main module to hold all RubyGem classes/modules.
#
module Gem

  class Exception < RuntimeError; end

  RubyGemsVersion = "0.7"
  RubyGemsPackageVersion = RubyGemsVersion + ".0"

  DIRECTORIES = ['cache', 'doc', 'gems', 'specifications']
  
  @@cache = nil  
  
  class << self
  
    def manage_gems
      require 'rubygems/user_interaction'
      require 'rubygems/builder'
      require 'rubygems/format'
      require 'rubygems/remote_installer'
      require 'rubygems/installer'
      require 'rubygems/validator'
      require 'rubygems/doc_manager'
      require 'rubygems/cmd_manager'
      require 'rubygems/gem_runner'
      require 'rubygems/config_file'
    end
  
    ##
    # Returns an Cache of specifications that are in the Gem.path
    #
    # return:: [Gem::Cache] cache of Gem::Specifications
    #
    def cache
      @@cache ||= Cache.from_installed_gems
      @@cache.refresh!
    end
    
    ##
    # The directory path where Gems are to be installed.
    #
    # return:: [String] The directory path
    #
    def dir
      @gem_home ||= nil
      set_home(ENV['GEM_HOME'] || default_dir) unless @gem_home
      @gem_home
    end
    
    ##
    # List of directory paths to search for Gems.
    #
    # return:: [List<String>] List of directory paths.
    #
    def path
      @gem_path ||= nil
      set_paths(ENV['GEM_PATH']) unless @gem_path
      @gem_path
    end
    
    ##
    # Reset the +dir+ and +path+ values.  The next time +dir+ or +path+
    # is requested, the values will be calculated from scratch.  This is
    # mainly used by the unit tests to provide test isolation.
    #
    def clear_paths
      @gem_home = nil
      @gem_path = nil
    end
    
    ##
    # Use the +home+ and (optional) +paths+ values for +dir+ and +path+.
    # Used mainly by the unit tests to provide environment isolation.
    #
    def use_paths(home, paths=[])
      set_home(home) if home
      set_paths(paths.join(File::PATH_SEPARATOR)) if paths
    end
    
    private
    
    # Set the Gem home directory (as reported by +dir+).
    def set_home(home)
      @gem_home = home
      ensure_gem_subdirectories(@gem_home)
    end
    
    # Set the Gem search path (as reported by +path+).
    def set_paths(gpaths)
      if gpaths
        @gem_path = gpaths.split(File::PATH_SEPARATOR)
        @gem_path << Gem.dir
      else
        @gem_path = [Gem.dir]
      end      
      @gem_path.uniq!
      @gem_path.each do |gp| check_gem_subdirectories(gp) end
    end
    
    # Default home directory path to be used if an alternate value is
    # not specified in the environment.
    def default_dir
      require 'rbconfig'
      File.join(Config::CONFIG['libdir'], 'ruby', 'gems', Config::CONFIG['ruby_version'])
    end
    
    # Ensure the named Gem directory contains all the proper subdirectories.
    def ensure_gem_subdirectories(gemdir)
      DIRECTORIES.each do |filename|
        fn = File.join(gemdir, filename)
        unless File.exists?(fn)
          require 'fileutils'
          FileUtils.mkdir_p(fn)
        end
      end
    end
    
    # Check that the given Gem directory contains all proper
    # subdirectories.  Print a warning to $stderr if not.
    def check_gem_subdirectories(gemdir)
      DIRECTORIES.each do |filename|
        fn = File.join(gemdir, filename)
        $stderr.puts "warning: GEM_PATH path #{fn} does not exist" unless File.exist?(fn)
      end
    end
  end
end

require 'rubygems/cache'
require 'rubygems/specification'
require 'rubygems/version'
