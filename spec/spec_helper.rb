# coding: utf-8

require 'rspec'
# require 'rspec/autorun'

# require 'LodViewRewrite'
# require '../lib/LodViewRewrite.rb'
$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'

require 'LodViewRewrite'
require 'pp'

RSpec.configure do |config|
  # include LodViewRewrite
  config.before :all do
  end
end
