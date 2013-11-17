#!/usr/bin/env ruby
# coding: utf-8

require 'optparse'
require "open3"
require 'cfpropertylist'
require 'find'
require 'socket'

require 'calasmash/command'
require 'calasmash/setup'
require 'calasmash/compiler'
require 'calasmash/plist'
require 'calasmash/cucumber'

module Calasmash
  PORT = 4567
end