require "calasmash/version"

require 'optparse'
require 'socket'
require 'cfpropertylist'
require 'find'
require 'open3'

module Calasmash
	class Runner

		def initialize(args)
			@options = parse(args)
			if @options[:valid] 
      			start
      		else
      			puts "Invalid options!"
    		end
		end	
		
		def start
			puts "Starting..."
			compile
			update_plist
			delete_simulator_plist
			sleep(2)
			run_cucumber
		end

		def parse(args)
			options = {}
			options[:tags] = []	
			@opt_parser = OptionParser.new do |opt|
		  		opt.banner = "Usage: calasmash [OPTIONS]"
		  		opt.separator  ""
		  		opt.separator  "Options"
		  
				opt.on("-t","--tags TAGS","the tags to pass to Cucumber") do |tag_set|
				    options[:tags] << tag_set
				end

				opt.on("-w","--workspace WORKSPACE","the workspace to build") do |tags|
				    options[:workspace] = tags
				end

				opt.on("-s","--scheme SCHEME","the scheme to build") do |tags|
				    options[:scheme] = tags
				end

				opt.on("-h","--help","help") do
				  puts @opt_parser
				end

				opt.on('-f', "--format FORMAT", "test report format e.g. junit") do |tags|
					options[:format] = tags
				end

				opt.on('-o', "--out OUTPUT", "test report output path e.g. test") do |tags|
					options[:out] = tags
				end

				opt.on('-ios', "--ios OS", "iOS simulator version of the sdk to run e.g. 6.0 or 7.0") do |tags|
					options[:ios] = tags
				end
			end

			@opt_parser.parse! args

			options[:valid] = true

			validate_options(options)
			return options
		end

		def validate_options(options)
			if options[:workspace].nil?
				puts "Workspace path required, see --help for more information"
				options[:valid] = false
			elsif options[:scheme].nil?
				puts "Scheme required, see --help for more information"
				options[:valid] = false
			end
			options
		end

		def compile
			puts "Compiling..."

			status = nil
			xcode_command = "xcodebuild -workspace #{@options[:workspace]} -scheme #{@options[:scheme]} -sdk iphonesimulator CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO"
			Open3.popen3 xcode_command do |stdin, out, err, wait_thr|

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
				puts "Compilation failed: #{status}"
				exit status
			end
		end

		def update_plist
			puts "Updating plist..."

			ip = Socket.ip_address_list.find {|a| a.ipv4? && !a.ipv4_loopback?}.ip_address
			port = 4567 #sinatras default port

			plist_file = CFPropertyList::List.new(:file => plist_path)
			plist = CFPropertyList.native_types(plist_file.value)
		
			plist["url_preference"] = ip
			plist["port_preference"] = port

			puts("plist: #{plist}")

			plist_file.value = CFPropertyList.guess(plist)
			plist_file.save(plist_path, CFPropertyList::List::FORMAT_XML)

		end

		def delete_simulator_plist
			puts "Deleting simulator plist..."
			# Delete last known simulator preference to prevent running in the wrong simulator
			 FileUtils.rm(simulator_plist_path, :force => true)
		end

		def run_cucumber
			puts "Running cucumber..."

			# Which iOS simulator to run if specified else uses default for the platform
			os_params = ""
			if(@options[:ios])
				os = @options[:ios]
				os_params = " OS=ios#{os.to_i} SDK_VERSION=#{os}"
			end
			
			optional_params = ""
			if(@options[:out] && @options[:format])
				optional_params = " --format #{@options[:format]} --out #{@options[:out]} "
			end

			if(@options[:tags])
				@options[:tags].each do |tag_set|
					optional_params += " --tags #{tag_set}"					
				end
			end

			cucumber_command = "cucumber"
			cucumber_command += os_params
			cucumber_command += " DEVICE_TARGET=simulator"
			cucumber_command += optional_params

			puts("#{cucumber_command}")

			status = nil
			Open3.popen3 cucumber_command do |stdin, out, err, wait_thr|

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
				puts "Cucumber failed: #{status}"
			end

			# exit with whatever status Cucumber has exited
			exit status
		end

		def app_path
			files = []
			
			Find.find("#{File.expand_path('~')}/Library/Developer/Xcode/DerivedData/") do |path|
  				files << path if path =~ /#{@options[:scheme]}.app$/
			end

			app_path = files.sort_by { |filename| File.mtime(filename)}.last # get the latest

			return app_path
		end 

		def plist_path
			
			plist_path = app_path + "/server_config.plist"
		 	return plist_path
		end

		def simulator_plist_path
			return "#{File.expand_path('~')}/Library/Preferences/com.apple.iphonesimulator.plist"
		end
	end
end


