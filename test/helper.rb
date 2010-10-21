require 'rubygems'
gem 'test-unit', '>= 2.1.0'
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require "spore"
require 'net/http'

class Test::Unit::TestCase
end
