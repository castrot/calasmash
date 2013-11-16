#!/usr/bin/env ruby
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
        scheme  = options[:scheme]
        ios     = options[:ios]
        tags    = options[:tags]
        format  = options[:format]
        output  = options[:output]

        # Compile the project
        compile(scheme) do
          # Update the plist
          update_plist(scheme)
          # Run the tests
          run_tests(ios, tags, format, output)
        end
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

          opt.on("-i", "--ios OS", "iOS simulator version of the sdk to run e.g. 6.0 or 7.0") do |tags|
            options[:ios] = tags
          end

          opt.on("-f", "--format FORMAT", "the format of the test reports to output") do |format|
            options[:format] = format
          end

          opt.on("-o", "--output OUTPUT", "the output path for the test results") do |output|
            options[:output] = output
          end
        end.parse!

        return options
      end

      #
      # Kick off a compile
      # @param  scheme [String] The scheme to compile
      # @param  &compiled [Block] Completion block
      #
      def compile(scheme, &compiled)
        compiler = Calasmash::Compiler.new(scheme)
        compiler.compile do |complete|
          yield
        end
      end

      #
      # Update the applications plist so that the application
      # connects to sinatra
      # @param  scheme [String] The scheme related to the application
      #
      def update_plist(scheme)
        plist = Calasmash::Plist.new(scheme)
        plist.execute
      end

      #
      # Run the cucumber tests, that's why we're here afterall
      #
      # @param  ios [String] The iOS version to test with
      # @param  tags [Array] The cucumber tags to test with
      # @param  format [String] The output format for the cucumber tests, Optional
      # @param  output [String] The path to the output directory to output test reports to, Optional
      def run_tests(ios, tags, format=nil, output=nil)
        cucumber = Calasmash::Cucumber.new(ios, tags)
        cucumber.format = format if format
        cucumber.output = output if output
        cucumber.test
      end

      #
      # Outputs a nice helpful banner overview to STDOUT
      #
      def overview
        s = "Usage: calasmash [OPTIONS]"
        s << "\n  --tags -t the tags to pass to cucumber, for multiple tags pass one per tag"
        s << "\n  --scheme -s the Xcode scheme to build"
        s << "\n  --ios -i the iOS version to build with"
        s << "\n  --output -o The output directory for the test report"
        s << "\n  --format -f The format of the test report"

        puts s
      end

    end
  end
end