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
        data.main_group.children.each do |child|
          p child.name
        end
      end

      def xcodeproj
        Dir["*.xcodeproj"].first
      end
    end
  end
end