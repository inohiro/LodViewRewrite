# coding: utf-8

module LodViewRewrite

  class Query

    attr_reader :limit

    def initialize( sparql = '', limit = 1000 )
      @raw = sparql
      @http = Net::HTTP::Persistent.new
      @structured = Hash.new
      @limit = limit
      unless sparql == ''
        @structured = parse
      end
    end

    attr_reader :row, :structured
    # attr_accessor :filters

    def prefixes; @structured['prefixes'] || []; end
    def options; @structured['options'] || []; end
    def patterns; @structured['patterns'] || []; end
    def operators; @structured['operators'] || []; end
    # def filters; @structured['filters']; end

    def parse
      parsed = SPARQL.parse( @raw )
      prefixes_enable = false

      if parsed.is_a? RDF::Query
        prefixes_enable = false
      elsif parsed.is_a? SPARQL::Algebra::Operator::Prefix
        if parsed.operands.size == 2
          prefixes_enable = true
        elsif parsed.operands.size == 1
          prefixes_enable = false
        else
          raise UnknownQueryStructureException, 'parsed.operator has more than 2 operands'
        end
      end

      if prefixes_enable
        parse_prefixes( parsed.operands[0] )
        @structured = parse_tree( parsed.operands[1] )
      else
        @structured = parse_tree( parsed )
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

    def to_sparql( condition = LodViewRewrite::Condition.new( [].to_json ) )
      # operators, options, patterns, prefixes, and filters
      sparql = ''

      ## PREFIX
      # sparql << prefixes.map { |prefix,uri| "PREFIX #{prefix} <#{uri}>" }.join( "\n" )

      # sparql << "\n"

      ## options

      ## Operators

      if condition.select != ""
        sparql = condition.select # inject condition
      else
        if operators.empty?
          sparql << "SELECT *"
        else
          operators.each do |type,vars|
            sparql << "#{type.upcase} #{vars.map(&:to_s).join( ' ' )}" if type
          end
        end
      end

      ## Patterns: WHERE Closure
      sparql << "\nWHERE {\n"
      patterns.each { |pattern| sparql << "  #{pattern}\n" }

      ## FILTERs
      condition.filters.each { |filter| sparql << "  #{filter}\n" } unless condition.filters.empty?

      sparql << "}"

      ## Operator: Order By
      ## Operator: Group By, Having

      sparql << "\nLIMIT #{@limit}"
      sparql
    end

    def exec_sparql( condition = [] )
      uri = URI "http://dbpedia.org/sparql" # !!

      # About request format
      # http://virtuoso.openlinksw.com/dataspace/doc/dav/wiki/Main/VOSSparqlProtocol

      sparql = to_sparql( condition )
      params = {
        'default-uri-graph' => "http://dbpedia.org", # !!
        'query' => sparql,
        'format' => 'application/json', # 'text/html'
        # 'timeout' => '30000',
        # 'debug' => 'on',
      }

      # response = RestClient.get( uri, :params => params )

      uri.query = URI.encode_www_form( params )
      response = @http.request uri

      case response
      when Net::HTTPOK
        return response.body
      else
        puts "QUERY: #{sparql}"
        throw UnExpectedReturnCode
      end
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
