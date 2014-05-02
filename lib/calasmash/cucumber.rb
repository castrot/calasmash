#!/usr/bin/env ruby
# coding: utf-8

module Calasmash

  #
  # Provides a nice interface to cucumber, allowing
  # us to run the cucumber test suite
  #
  # @author [alexfish]
  #
  class Cucumber

    # Public: the output directory for the tests
    attr_accessor :output

    # Public: the output format for the tests
    attr_accessor :format

    #
    # Create a new instance of Cucumber
    # @param  ios [String] The iOS version cucumber will run
    # @param  tags [Array] The tags cucumber will run with
    #
    def initialize(ios, tags)
      @ios = ios
      @tags = tags
    end

    #
    # Run the cucumber tests
    #
    def test
      started

      status = nil
      output = ""
      Open3.popen3 command do |stdin, out, err, wait_thr|

        [out, err].each do |stream|
          Thread.new do
            until (line = stream.gets).nil? do
              puts line
            end
          end
        end

        wait_thr.join
        status = wait_thr.value.exitstatus
      end

      if status != 0
        puts "\n Cucumber failed"
        exit status
      else
        completed
      end
    end

    private

    #
    # Output a nice message for starting
    #
    def started
      puts "\nRunning Cucumber"
      puts "================\n"
    end

    #
    # Output a nice message for completing
    #
    def completed
      puts "\nCucumber Completed 👌"
    end

    #
    # Figure out what the cucumber command is and
    # return it
    #
    # @return [String] The cucumber command string
    def command
      command = "cucumber"
      command += simulator_arguments if @ios
      command += " --format #{self.format}" if self.format
      command += " --out #{self.output}" if self.output
      command += @tags.to_a.empty? ? "" : tag_arguments
      command += " -c"

      command
    end

    #
    # Generate the --tags arguments for the cucumber
    # command
    #
    # @return [String] The --tags commands ready to go
    def tag_arguments
      command = ""
      @tags.each do |tag_set|
        command = "" unless command
        command += " --tags #{tag_set}"
      end
      command
    end

    #
    # Generate the simulator version arguments that
    # are best for certain versions of simulators
    #
    # @return [String] The simulator arguments
    def simulator_arguments
      if @ios
          command = " DEVICE_TARGET='iPhone Retina (4-inch) - Simulator - iOS #{@ios}'"
      end

      command
    end

  end
end
