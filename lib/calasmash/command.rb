# coding: utf-8

module Calasmash

  #
  # The main point of entry for all commands, Command parses command line arguments
  # and decides what to do about them.
  #
  # @author [alexfish]
  #
  class Command

    class << self

      #
      # Execute a command with some arguments
      # then figure out what we're supposed to be doing with
      # the arguments
      #
      # @param  *args [Array] An Array of arguments to play with
      #
      # @return [type] [description]
      def execute(*args)
        return overview unless args.length > 1

        options = parse(args)

        # Compile the project
        compile(options[:scheme])
      end

      #
      # parse the arguments and act on them
      # @param  args [Array] The arguments from execute
      #
      # @return [Hash] A hash containing all of our options
      def parse(args)
        options = {}
        options[:tags] = []

        OptionParser.new do |opt|
         opt.on("-s","--scheme SCHEME","the scheme to build") do |tags|
            options[:scheme] = tags
          end

          opt.on("-t","--tags TAGS","the tags to pass to Cucumber") do |tag_set|
            options[:tags] << tag_set
          end

          opt.on('-i', "--ios OS", "iOS simulator version of the sdk to run e.g. 6.0 or 7.0") do |tags|
            options[:ios] = tags
          end
        end.parse!

        return options
      end

      def compile(scheme)
        compiler = Calasmash::Compiler.new(scheme)
        compiler.compile
      end

      #
      # Outputs a nice helpful banner overview to STDOUT
      #
      def overview
        s = "Usage: calasmash [OPTIONS]"
        s << "\n  --tags -t the tags to pass to Cucumber"
        s << "\n  --scheme -s the Xcode scheme to build"
        s << "\n  --ios -i the iOS version to build with"

        puts s
      end

    end
  end
end