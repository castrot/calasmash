# coding: utf-8

module Calasmash

  #
  # The calamsash compiler will compiles the Xcode project with the
  # scheme it's told to compile with.
  #
  # @author [alexfish]
  #
  class Compiler

    # Public: the Scheme the compiler is compiling
    attr_accessor :scheme

    def initialize(scheme)
      @scheme = scheme
    end

    #
    # The compiler's heart, executes the compiling with xcodebuild
    #
    #  @param &complete Compleition block
    #
    # Returns nothing because it completes with a complete block
    def compile(&complete)
      started
      status = nil
      output = ""

      Open3.popen3 command do |stdin, out, err, wait_thr|
        [out, err].each do |stream|
          Thread.new do
            until (line = stream.gets).nil? do
              print "."
              output << line
            end
          end
        end
        wait_thr.join
        status = wait_thr.value.exitstatus
      end

      if status != 0
        puts "\n Compilation failed: \n\n #{output}"
        exit status
      else
        completed
        complete.call(true) if complete
      end
    end

    private

    #
    # Output a nice message for starting
    #
    def started
      puts "\nCompiling"
      puts "=========\n"
    end

    #
    # Output a nice message for completing
    #
    def completed
      puts "\n\nCompiled 👌"
    end

    def command
      xcode_command = "xcodebuild -workspace #{workspace} \
                       -scheme #{@scheme} \
                       -sdk iphonesimulator \
                       CODE_SIGN_IDENTITY="" \
                       CODE_SIGNING_REQUIRED=NO"

      xcode_command
    end

    #
    # Looks in the current directory for the workspace file and
    # gets it's name
    #
    # @return [String] The name of the workspace file that was found
    def workspace
      Dir["*.xcworkspace"].first
    end

  end
end
