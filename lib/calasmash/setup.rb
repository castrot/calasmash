require 'xcodeproject'

module Calasmash

  #
  # Runs setup tasks so that the user can get started
  # with calasmash easily.
  #
  # @author [alexfish]
  #
  class Setup

    class << self

      #
      # Execute the setup process and get things started
      #
      def execute
        #input = $stdin.gets.chomp
        add_plist
      end

      private


      #
      # Add the data/calasmash.plist file to the Xcode project
      # using the xcodeproject gem
      #
      def add_plist
        proj = XcodeProject::Project.new(xcodeproj)
        data = proj.read
        puts selected_group(data)
      end

      #
      # Output the available groups to the console and
      # let the user select one
      #
      # @param data [XcodeProject] The Xcode project to select a group from
      #
      # @return [XcodeProject::PBXGroup] The selected Xcode group
      def selected_group(data)
        puts "Selet a group for the calasmash server config plist:\n\n"
        groups = {}
        data.main_group.children.each_with_index do |child, i|
          groups[i] = child
          puts "#{i + 1}. #{child.name}"
        end
        option = $stdin.gets.chomp
        groups[option.to_i - 1]
      end

      def xcodeproj
        Dir["*.xcodeproj"].first
      end
    end
  end
end