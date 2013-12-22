# coding: utf-8

module LodViewRewrite
  class Filters

    def initialize( json = '' )
      unless json == ''
        @json = json
        @loaded = ''
        parse
      end
    end

    def parse
      @loaded = JSON.load( @json )
    end

    def to_s
      build_filter_from_condition_set.join( "\n" )
    end

    # condition format:
    #   a condition is noted as a Hash.
    #
    # filter type & example:
    #   regex: "FILTER regex ( variable, "litelra" [ ,flag ] )"
    #     { :type => "regex", :var => "?name", :condition => "^ino", :flag => "i" }
    #     flag: http://www.w3.org/TR/sparql11-query/#func-regex
    #
    #   exists: "FILTER EXISTS ( Subject Predicate Obejct )"
    #     { type: "exists", subject: "sbj", predicate: "pred", object: "obj" }
    #
    #   not_exists: "FILTER NOT EXISTS ( Subject Predicate Object )"
    #     { type: "not_exists", subject: "sbj", predicate: "pred", object: "obj" }
    #
    #   normal: "FILTER ( variable operator condition )"
    #     { type: "normal", var: "?age", operator: "<", condition: "30" }
    #

    def build_filter_from_condition( condition = [] )
      filter = "FILTER "

      case condition['type']
      when 'regex'
        # build_regex_filter( condition )
        filter << "regex ( #{hatenize( condition['var'] )}, \"#{condition['condition']}\""
        filter << ", \"#{condition['flag']}\"" if condition['flag']
        filter << " )"
      when 'exists'
        filter << "EXISTS ( #{condition['subject']} #{condition['predicate']} #{condition['object']} )"
      when 'not_exists'
        filter << "NOT EXISTS ( #{condition['subject']} #{condition['predicate']} #{condition['object']} )"
      when 'normal'
        filter << "( #{hatenize( condition['var'] )} #{condition['operator']} #{condition['condition']} )"
      else
        raise UnknownFilterConditionType
      end
      filter
    end
    private :build_filter_from_condition

    def build_filter_from_condition_set
      return [] unless @loaded.class == Array
      @loaded.map { |condition| build_filter_from_condition( condition ) }
    end
    private :build_filter_from_condition_set

    def hatenize( variable )
      chars = variable.split( // )
      chars.unshift( '?' ) if chars.first != '?'
      chars.join
    end

  end
end
