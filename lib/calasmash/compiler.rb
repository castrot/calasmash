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
    #  @param  &complete [type] [description]
    #
    # Returns nothing because it completes with a complete block
    def compile &complete
      status = nil
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
            end
          end
        end
        wait_thr.join
        status = wait_thr.value.exitstatus
      end

      if status != 0
        puts "\n Compilation failed: #{status}"
        exit status
      else
        puts "\nCompiled 👌"
      end
    end

    #
    # Looks in the current directory for the workspace file and
    # gets it's name
    #
    # @return [String] The name of the workspace file that was found
    def workspace
      "laterooms.xcworkspace"
    end

  end

end

#   def compile
#     puts "Compiling..."
#
#     status = nil
#     xcode_command = "xcodebuild -workspace #{@options[:workspace]} -scheme #{@options[:scheme]} -sdk iphonesimulator CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO"
#     Open3.popen3 xcode_command do |stdin, out, err, wait_thr|
#
#       [out, err].each do |stream|
#         Thread.new do
#           until (line = stream.gets).nil? do
#             puts line
#           end
#         end
#       end
#
#       wait_thr.join
#       status = wait_thr.value.exitstatus
#     end
#
#     if status != 0
#       puts "Compilation failed: #{status}"
#       exit status
#     end
#   end