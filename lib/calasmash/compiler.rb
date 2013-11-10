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
      status = nil
      output = ""
      xcode_command = "xcodebuild -workspace #{workspace} \
                       -scheme #{@scheme} \
                       -sdk iphonesimulator \
                       CODE_SIGN_IDENTITY="" \
                       CODE_SIGNING_REQUIRED=NO"

      Open3.popen3 xcode_command do |stdin, out, err, wait_thr|
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
        puts "\nCompiled 👌"
        complete.call(true) if complete
      end
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
