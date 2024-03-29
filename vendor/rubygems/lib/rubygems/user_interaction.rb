module Gem

  ##
  # Module that defines the default UserInteraction.  Any class
  # including this module will have access to the +ui+ method that
  # returns the default UI.
  module DefaultUserInteraction

    # Return the default UI.
    def ui
      DefaultUserInteraction.ui
    end

    # Set the default UI.  If the default UI is never explicity set, a
    # simple console based UserInteraction will be used automatically.
    def ui=(new_ui)
      DefaultUserInteraction.ui = new_ui
    end

    def use_ui(new_ui, &block)
      DefaultUserInteraction.use_ui(new_ui, &block)
    end

    # The default UI is a class variable of the singleton class for
    # this module.
    class << self
      def ui
	@ui ||= Gem::ConsoleUI.new
      end
      def ui=(new_ui)
	@ui = new_ui
      end
      def use_ui(new_ui)
	old_ui = @ui
	@ui = new_ui
	yield
      ensure
	@ui = old_ui
      end
    end
  end

  ##
  # Make the default UI accessable without the "ui." prefix.  Classes
  # including this module may use the interaction methods on the
  # default UI directly.  Classes may also reference the +ui+ and
  # <tt>ui=</tt> methods.
  #
  # Example:
  #
  #   class X
  #     include Gem::UserInteraction
  #
  #     def get_answer
  #       n = ask("What is the meaning of life?")
  #     end
  #   end
  module UserInteraction
    include DefaultUserInteraction
    [
      :choose_from_list, :ask, :say, :alert, :alert_warning,
      :alert_error, :terminate_interaction!, :terminate_interaction
    ].each do |methname|
      class_eval %{
        def #{methname}(*args)
          ui.#{methname}(*args)
        end
      }
    end    
  end

  ##
  # StreamUI implements a simple stream based user interface.
  class StreamUI
    def initialize(in_stream, out_stream, err_stream=STDERR)
      @ins = in_stream
      @outs = out_stream
      @errs = err_stream
    end
    
    # Choose from a list of options.  +question+ is a prompt displayed
    # above the list.  +list+ is a list of option strings.  Returns
    # the pair [option_name, option_index].
    def choose_from_list(question, list)
      @outs.puts question
      list.each_with_index do |item, index|
        @outs.puts " #{index+1}. #{item}"
      end
      @outs.print "> "
      @outs.flush
      result = @ins.gets.strip.to_i - 1
      return list[result], result
    end
    
    # Ask a question.  Returns an answer.  
    def ask(question)
      @outs.print(question + "  ")
      @outs.flush
      result = @ins.gets
      result.chomp! if result
      result
    end
    
    # Display a statement.
    def say(statement="")
      @outs.puts statement
    end
    
    # Display an informational alert.
    def alert(statement, question=nil)
      @outs.puts "INFO:  #{statement}"
      return ask(question) if question 
    end
    
    # Display a warning in a location expected to get error messages.
    def alert_warning(statement, question=nil)
      @errs.puts "WARNING:  #{statement}"
      ask(question) if question 
    end
    
    # Display an error message in a location expected to get error
    # messages.
    def alert_error(statement, question=nil)
      @errs.puts "ERROR:  #{statement}"
      ask(question) if question
    end

    # Terminate the application immediately without running any exit
    # handlers.
    def terminate_interaction!(status=-1)
      exit!(status)
    end
    
    # Terminate the appliation normally, running any exit handlers
    # that might have been defined.
    def terminate_interaction(status=0)
      exit(status)
    end
  end


  ##
  # Subclass of StreamUI that instantiates the user interaction using
  # standard in, out and error.
  class ConsoleUI < StreamUI
    def initialize
      super(STDIN, STDOUT, STDERR)
    end
  end
end


