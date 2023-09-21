class String
  ##
  # To simplify conversion code.
  #
  def to_requirement
    Gem::Version::Requirement.new([self])
  end
end

module Gem
  
  ##
  # The Dependency class holds a Gem name and Version::Requirement
  #
  class Dependency
    attr_accessor :name, :version_requirements
    
    ##
    # Constructs the dependency
    #
    # name:: [String] name of the Gem
    # version_requirements:: [String Array] version requirement (e.g. ["> 1.2"])
    #
    def initialize(name, version_requirements)
      @name = name
      @version_requirements = Version::Requirement.new(version_requirements)
    end

    def version_requirements
      normalize if @version_requirement
      @version_requirements
    end

    def requirement_list
      version_requirements.as_list
    end

    def normalize
      ver = @version_requirement.instance_eval { @version }
      @version_requirements = Version::Requirement.new([ver])
      @version_requirement = nil
    end
  end
  
  ##
  # The Version class processes string versions into comparable values
  #
  class Version
    include Comparable

    attr_accessor :version

    NUM_RE = /\s*(\d+(\.\d+)*)*\s*/
    
    ##
    # Constructs a version from the supplied string
    #
    # version:: [String] The version string.  Format is digit.digit...
    #
    def initialize(version)
      raise ArgumentError, 
        "Malformed version number string #{version}" unless correct?(version)
      @version = version
    end
    
    ##
    # Returns the text representation of the version
    #
    # return:: [String] version as string
    #
    def to_s
      @version
    end
    
    ##
    # Checks if version string is valid format
    #
    # str:: [String] the version string
    # return:: [Boolean] true if the string format is correct, otherwise false
    #
    def correct?(str)
      /^#{NUM_RE}$/.match(str)
    end
    
    ##
    # Convert version to integer array
    #
    # return:: [Array] list of integers
    #
    def to_ints
      @version.scan(/\d+/).map {|s| s.to_i}
    end
    
    ##
    # Compares two versions
    #
    # other:: [Version or .to_ints] other version to compare to
    # return:: [Fixnum] -1, 0, 1
    #
    def <=>(other)
      rnums, vnums = to_ints, other.to_ints
      [rnums.size, vnums.size].max.times {|i|
        rnums[i] ||= 0
        vnums[i] ||= 0
      }
      
      begin
        r,v = rnums.shift, vnums.shift
      end until (r != v || rnums.empty?)

      return r <=> v
    end

    # Return a new version object where the next to the last revision
    # number is one greater. (e.g.  5.3.1 => 5.4)
    def bump
      ints = to_ints
      ints.pop if ints.size > 1
      ints[-1] += 1
      self.class.new(ints.join("."))
    end
    
    ##
    # Requirement version includes a prefaced comparator in addition
    # to a version number.
    #
    class Requirement
      include Comparable

      OPS = {
	"="  =>  lambda { |v, r| v == r },
	"!=" =>  lambda { |v, r| v != r },
	">"  =>  lambda { |v, r| v > r },
	"<"  =>  lambda { |v, r| v < r },
	">=" =>  lambda { |v, r| v >= r },
	"<=" =>  lambda { |v, r| v <= r },
	"~>" =>  lambda { |v, r| v >= r && v < r.bump }
      }
        
      OP_RE = Regexp.new(OPS.keys.collect{|k| Regexp.quote(k)}.join("|"))
      REQ_RE = /\s*(#{OP_RE})\s*/

      ##
      # Constructs a version requirement instance
      #
      # str:: [String Array] the version requirement string (e.g. ["> 1.23"])
      #
      def initialize(reqs)
	@requirements = reqs.collect do |rq|
	  op, version_string = parse(rq)
	  [op, Version.new(version_string)]
	end
      end

      ##
      # Used to simplify conversion code, especially from strings
      #
      def to_requirement
        self
      end
      
      ##
      # Overrides to check for comparator
      #
      # str:: [String] the version requirement string
      # return:: [Boolean] true if the string format is correct, otherwise false
      #
      def correct?(str)
        /^#{REQ_RE}#{NUM_RE}$/.match(str)
      end
      
      def to_s
	as_list.join(", ")
      end

      def as_list
	normalize
	@requirements.collect { |req|
          "#{req[0]} #{req[1]}"
	}
      end
      
      def normalize
	return if @version.nil?
	@requirements = [parse(@version)]
	@nums = nil
	@version = nil
	@op = nil
      end
      
      ##
      # Is the requirement satifised by +version+.
      #
      # version:: [Gem::Version] the version to compare against
      # return:: [Boolean] true if this requirement is satisfied by
      #          the version, otherwise false 
      #
      def satisfied_by?(version)
	normalize
	@requirements.all? { |op, rv| satisfy?(op, version, rv) }
      end
  
      private
       
      ##
      # Is "version op required_version" satisfied?
      #
      def satisfy?(op, version, required_version)
	OPS[op].call(version, required_version)
      end

      ##
      # Parse the version requirement string. Return the operator and
      # version strings.
      #
      def parse(str)
	if md = /^\s*(#{OP_RE})\s*([0-9.]+)\s*$/.match(str)
	  [md[1], md[2]]
	elsif md = /^\s*([0-9.]+)\s*$/.match(str)
	  ["=", md[1]]
	elsif md = /^\s*(#{OP_RE})\s*$/.match(str)
	  [md[1], "0"]
	else
	  fail ArgumentError, "Illformed requirement [#{str}]"
	end
      end

      def <=>(other)
	to_s <=> other.to_s
      end

    end
  end
end
