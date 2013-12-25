# coding: utf-8

module LodViewRewrite

  class Query

    def initialize( sparql = '' )
      @raw = sparql
      @structured = Hash.new
      # @structured.store( 'filters', [] )
      unless sparql == ''
        @structured = parse
      end
    end

    attr_reader :row, :structured
    # attr_accessor :filters

    def prefixes; @structured['prefixes']; end
    def options; @structured['options']; end
    def patterns; @structured['patterns']; end
    def operators; @structured['operators']; end
    # def filters; @structured['filters']; end

    def parse
      parsed = SPARQL.parse( @raw )
      prefixes_enable = false
      if parsed.operands.size == 2
        prefixes_enable = true
      elsif parsed.operands.size == 1
        prefixes_enable = false
      else
        raise UnknownQueryStructureException, 'parsed.operator has more than 2 operands'
      end

      if prefixes_enable
        parse_prefixes( parsed.operands[0] )
        @structured = parse_tree( parsed.operands[1] )
      else
        @structured = parse_tree( parsed.operands[0] )
      end

      @structured
    end
    private :parse

    def parse_prefixes( prefixes )
      prefix_h = {}
      prefixes.each { |prefix| prefix_h.store( prefix[0].to_s, prefix[1].to_s ) }
      @structured.store( 'prefixes', prefix_h )
    end
    private :parse_prefixes

    def parse_operator( tree )
      operators = Hash.new
      operators = @structured['operators'] if @structured.key? 'operators'

      case tree
      when SPARQL::Algebra::Operator::Project
        operators.store( 'select', tree.operands[0].map(&:to_s))
      else
        raise UnsupportedOperatorException, "#{tree}"
      end

      @structured.store( 'operators', operators )
    end
    private :parse_operator

    def parse_patterns( patterns )
      @structured.store( 'patterns', patterns.map(&:to_s) )
    end
    private :parse_patterns

    def parse_options( options )
      hash = {}
      options.each { |key,value| hash.store( key.to_s, value.to_s ) }
      @structured.store( 'options', hash )
    end
    private :parse_options

    def parse_tree( tree )
      if tree.kind_of? SPARQL::Algebra::Operator
        parse_operator( tree )
        parse_tree( tree.operands[1] )
      elsif tree.kind_of? RDF::Query
        parse_options( tree.options )
        parse_patterns( tree.patterns )
      else
        raise UnknownQueryStructureException, 'Query tree has something that is not Operator or Query'
      end

      @structured
    end
    private :parse_tree

    def to_json
      @structured.to_json
    end

    # filter, projection

    def to_sparql( filters = "" )
      # operators, options, patterns, prefixes, and filters
      sparql = ''

      ## PREFIX
      # sparql << prefixes.map { |prefix,uri| "PREFIX #{prefix} <#{uri}>" }.join( "\n" )

      sparql << "\n"

      ## options

      ## Operator: SELECT Closure
      operators.each do
      end

      operators.each do |type,vars|
        sparql << "#{type.upcase} #{vars.map(&:to_s).join( ' ' )}"
      end

      ## Patterns: WHERE Closure
      sparql << "\nWHERE {\n"
      # sparql << patterns.join( "\n" )
      patterns.each { |pattern| sparql << "  #{pattern}\n" }

      ## FILTERs
      # sparql << filters.to_s
      filters.to_a.each { |filter| sparql << "  #{filter}\n" }

      sparql << "}"

      ## Operator: Order By
      ## Operator: Group By
      ## Operator: Having

      sparql
    end

    # def build_operator_query
    #   @structured['operators'].each do |operator|
    #     operator.each do |type,vars|
    #       case type
    #       when 'project'
    #       else
    #       end
    #     end
    #   end
    # end

  end
end
