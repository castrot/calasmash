calasmash
=========

[![Gem Version](https://badge.fury.io/rb/calasmash.png)](http://badge.fury.io/rb/calasmash)
[![Build Status](https://travis-ci.org/ustwo/calasmash.png?branch=master)](https://travis-ci.org/ustwo/calasmash)

Calasmash provides an interface to run a suite of calabash-ios tests against an iOS application using a mocked backend.

## Installation

Add this line to your application's Gemfile:

    gem 'calasmash'

And then execute:

    $ bundle install

## Usage

Simply run the command below with your preferred arguments.

    calasmash

### Options

    --tags -t the tags to pass to Cucumber, for multiple tags pass one -t option per tag
    --scheme -s the Xcode scheme to build
    --ios -i the iOS version to build with
    --output -o The output directory for the test report
    --format -f The format of the test report

## Configuration 

Your cucumber tests will need to start a Sinatra server before running with the launch `Before` step.

The iOS application should contain a `server_config.plist` file in the following format:

[Sample plist](https://gist.github.com/alexfish/7505037)

calasmash will update the port and url values before launching the application, your iOS application will need to use the plist values when running it's calabash-ios target.

You can then use a method along these lines to get the url in the iOS application when running the calabash target and direct any API requests to the url.

[Sample method](https://gist.github.com/alexfish/7505005)

## Contributing 

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
