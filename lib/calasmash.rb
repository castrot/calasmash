require "calasmash/version"

require 'optparse'
require 'socket'
require 'cfpropertylist'
require 'find'

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
			sleep(2)
			run_cucumber
		end

		def parse(args)
			options = {}	
			@opt_parser = OptionParser.new do |opt|
		  		opt.banner = "Usage: calasmash [OPTIONS]"
		  		opt.separator  ""
		  		opt.separator  "Options"
		  
				opt.on("-t","--tags TAGS","the tags to test against") do |tags|
				    options[:tags] = tags
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
			IO.popen("xcodebuild -workspace #{@options[:workspace]} -scheme #{@options[:scheme]} -sdk iphonesimulator CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO") {|output|
				puts output.read
			}
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

		def run_cucumber
			puts "Running cucumber..."

			optional_params = ""
			if(@options[:out] && @options[:format])
				optional_params = " --format #{@options[:format]} --out #{@options[:out]} "
			end

			if(@options[:tags])
				optional_params += " --tags #{@options[:tags]}"
			end

			cucumber_command = "cucumber OS=ios7 SDK_VERSION=7.0 DEVICE_TARGET=simulator"
			cucumber_command += optional_params

			IO.popen(cucumber_command) {|output|
				puts output.read
			}

			# exit with whatever status cucumber has exited
			exit $?.to_i
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
	end
end


