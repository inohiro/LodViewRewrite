# coding: utf-8
$LOAD_PATH << File.dirname(__FILE__) unless $LOAD_PATH.include?(File.dirname(__FILE__))

require 'pp'
require 'sparql'
require 'rest_client'

require 'lod_view_rewrite/query.rb'
require 'lod_view_rewrite/filters.rb'

module LodViewRewrite

  class UnExpectedReturnCode < Exception; end
  class EmptyQueryException < Exception; end
  class UnknownFilterConditionType < Exception; end
  class UnknownQueryStructureException < Exception; end
  class UnsupportedOperatorException < Exception; end
end
