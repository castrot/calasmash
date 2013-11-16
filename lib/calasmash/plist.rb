#!/usr/bin/env ruby
# coding: utf-8

module Calasmash

  #
  # Does some fun stuff with Xcode plists, calasmash needs to update
  # the Xcode projects plist to trick the simulator into connecting
  # to a sinatra server instead
  #
  # @author [alexfish]
  #
  class Plist

    # Public: the Scheme the plist is related to
    attr_accessor :scheme

    #
    # Create a new plist instance
    # @param  scheme [String] The scheme related to the plist
    #
    # @return [Plist] A plist instance
    def initialize(scheme)
      @scheme = scheme
    end

    #
    # Executes the plist tasks update and clear the old plists
    #
    def execute
      started
      update
      clear

      completed
    end

    private

    #
    # Output a nice message for starting
    #
    def started
      puts "\nUpdating plist"
      puts "=============="
    end

    #
    # Output a nice message for completing
    #
    def completed
      puts "Plist updated 👌"
    end

    #
    # Update the Xcode applications server.plist file
    # with sinatras port and URL
    #
    def update
      plist_file = CFPropertyList::List.new(:file => server_plist_path)
      plist = CFPropertyList.native_types(plist_file.value)

      plist["url_preference"] = server_ip
      plist["port_preference"] = Calasmash::PORT

      plist_file.value = CFPropertyList.guess(plist)
      plist_file.save(server_plist_path, CFPropertyList::List::FORMAT_XML)
    end

    #
    # Clear the existing plist from the iOS simulator
    #
    def clear
      FileUtils.rm(simulator_plist_path, :force => true)
    end

    #
    # The local IP address of the mock backend server
    #
    # @return [String] The mock backends IP
    def server_ip
      Socket.ip_address_list.find {|a| a.ipv4? && !a.ipv4_loopback?}.ip_address
    end

    #
    # The path to the iOS simulators plist
    #
    # @return [String] The path to the plist
    def simulator_plist_path
      "#{File.expand_path('~')}/Library/Preferences/com.apple.iphonesimulator.plist"
    end

    #
    # The path to the application
    #
    # @return [String] The path to the application
    def app_path
      files = []

      Find.find("#{File.expand_path('~')}/Library/Developer/Xcode/DerivedData/") do |path|
        files << path if path =~ /#{@scheme}.app$/
      end

      files.sort_by { |filename| File.mtime(filename)}.last # get the latest
    end

    #
    # The path to the server config plist
    #
    # @return The full path to the server config plist
    def server_plist_path
      app_path + "/server_config.plist"
    end

  end
end
