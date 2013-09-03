calasmash
=========

A hacky gem to compile a calabash ios target, set some settings bundle values then run cucumber tests

## Installation

Add this line to your application's Gemfile:

    gem 'calasmash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install calasmash

## Usage

Simply run the command below and pass valid options, workspace and scheme are required. 

    calasmash

### Options

    -t, --tags TAGS                  the cucumber tags to test against
    -w, --workspace WORKSPACE        the workspace to build
    -s, --scheme SCHEME              the scheme to build
    -h, --help                       help

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
