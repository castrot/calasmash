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
        puts "\n\nCucumber Completed 👌"
      end
    end

    private

    #
    # Figure out what the cucumber command is and
    # return it
    #
    # @return [String] The cucumber command string
    def command

      if(@ios)
       os_params = " OS=ios#{@ios.to_i} SDK_VERSION=#{@ios}"
      end

      @tags.each do |tag_set|
        optional_params += " --tags #{tag_set}"
      end

      command = "cucumber"
      command += os_params
      command += " DEVICE_TARGET=simulator"
      command += " --format junit --out test-reports" + optional_params

      puts command
      command
    end

  end
end

