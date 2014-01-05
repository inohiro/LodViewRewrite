# coding: utf-8

require 'spec_helper.rb'

describe LodViewRewrite::Query do

  context 'when limit is fixed' do
    let (:sparql) { "SELECT * WHERE { ?s <http://example.com/predicate> ?o . }" }
    let (:query) { LodViewRewrite::Query.new( sparql, 2000 ) }

    it 'limit is fixed' do
      query.limit.should eq 2000
    end

    it 'appears in re-written query' do
      cond = [
        {"FilterType"=>"3", "ConditionType"=>"System.String", "Variable"=>"o", "Condition"=>"hoge", "Operator"=>"="}
      ].to_json
      conditions = LodViewRewrite::Condition.new( cond )
      expected =<<EOQ
SELECT *
WHERE {
  ?s <http://example.com/predicate> ?o .
  FILTER (str(?o) = \"hoge\")
}
LIMIT 2000
EOQ
      query.to_sparql( conditions ).should eq expected.strip!
    end
  end

  context 'when simple query without conditions' do
    before :each do
      sparql =<<EOQ
SELECT *
WHERE {
  ?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> .
}
EOQ
      @query = LodViewRewrite::Query.new sparql
    end

    it 'to_sparql will be success' do
      @query.to_sparql.should_not be_empty
    end
  end

  context 'when simple query without PREFIX' do
    before :each do
      sparql =<<EOQ
SELECT *
WHERE {
  ?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> .
}
EOQ
      @query = LodViewRewrite::Query.new sparql
    end

    it 'can be parsed' do
      @query.should_not eq nil
    end

    it 'prefixes will be empty' do
      @query.prefixes.should be_empty
    end

    it 'options will be empty' do
      pending 'I should check default values'
      @query.options.should be_empty
    end

    it 'patterns will be accessed' do
      @query.patterns.should_not be_empty
      @query.patterns.first.should eq "?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> ."
    end

    it 'can be injected a condition' do
      cond = [
        {"FilterType"=>"3", "ConditionType"=>"System.String", "Variable"=>"subject", "Condition"=>"hoge", "Operator"=>"="}
      ].to_json
      conditions = LodViewRewrite::Condition.new( cond )
      expected =<<EOQ
SELECT *
WHERE {
  ?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> .
  FILTER (str(?subject) = \"hoge\")
}
LIMIT 1000
EOQ
      @query.to_sparql( conditions ).should eq expected.strip!
    end

  end

  context 'when sinple query' do
    before :each do
      @sparql =<<EOQ.freeze
PREFIX dbpprop: <http://dbpedia.org/property/>
PREFIX dbpr: <http://dbpedia.org/resource/>
SELECT *
WHERE {
  ?subject dbpprop:prefecture dbpr:Tokyo .
}
EOQ
      @query = LodViewRewrite::Query.new @sparql
    end

    it 'can parsed' do
      @query.should_not eq nil
    end

    it 'can access to prefixes' do
      @query.prefixes.should_not eq nil
      @query.prefixes.size.should eq 2
      @query.prefixes['dbpr'] == "http://dbpedia.org/resource/"
    end

    it 'can acccess to options' do
      pending 'should check default values'
      @query.options.should be_empty
    end

    it 'can access to patterns' do
      @query.patterns.should_not be_empty
      @query.patterns.count.should eq 1
      @query.patterns.first.should eq "?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> ."
    end

    it 'can access to operators' do
      @query.operators.should_not eq nil
      @query.operators.should be_empty # 'SELECT *' will be no operator
    end

    it 'can parse to SPARQL' do
      expected =<<EOQ
SELECT *
WHERE {
  ?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> .
}
LIMIT 1000
EOQ
      @query.to_sparql.should eq expected.strip!
    end

    it 'can be injected FILTER condition' do
      cond = [
        {"FilterType"=>"3", "ConditionType"=>"System.String", "Variable"=>"subject", "Condition"=>"hoge", "Operator"=>"="}
      ].to_json
      conditions = LodViewRewrite::Condition.new( cond )
      expected =<<EOQ
SELECT *
WHERE {
  ?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> .
  FILTER (str(?subject) = \"hoge\")
}
LIMIT 1000
EOQ
      @query.to_sparql( conditions ).should eq expected.strip!
    end

    context 'inject aggregation condition' do
      let (:cond) { [
          {"AggregationType"=>"3", "Variable"=>"subject"}
        ] }
      let (:conditions) { LodViewRewrite::Condition.new( cond.to_json ) }

      it 'can generate query correctly' do
        expected =<<EOQ
SELECT (COUNT(?subject) AS ?count_subject)
WHERE {
  ?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> .
}
LIMIT 1000
EOQ
        @query.to_sparql( conditions ).should eq expected.strip!
      end

      it 'can execute sparql to dbpedia.org' do
        expected = /42/
        expect( JSON.parse( @query.exec_sparql( conditions ) ).to_s ).to match( expected )
      end
    end

    it 'can be injected complex conditions' do
      cond = [
        {"SelectionType"=>'1', "Variables"=>[
            {"Variable"=>"subject", "Condition"=>"", "Operator"=>"", "SelectionType"=>'0'},
            {"Variable"=>"age", "Condition"=>"", "Operator"=>"", "SelectionType"=>'0'}]},
        {"Variable"=>"subject", "Condition"=>"http://dbpedia.org/resource/Minato,_Tokyo", "Operator"=>"=", "FilterType"=>'3', "ConditionType"=>"System.String"} ]
      conditions = LodViewRewrite::Condition.new( cond.to_json )
      expected =<<EOQ
SELECT ?subject ?age
WHERE {
  ?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> .
  FILTER (str(?subject) = \"http://dbpedia.org/resource/Minato,_Tokyo\")
}
LIMIT 1000
EOQ
      @query.to_sparql( conditions ).should eq expected.strip!
    end

    context 'can be inject complex aggregation conditions' do
      let (:cond) { [
        {"Variable"=>"subject", "Condition"=>"http://dbpedia.org/resource/Minato,_Tokyo", "Operator"=>"=", "FilterType"=>'3',"ConditionType"=>"System.String"},
        {"Variable"=>"subject", "AggregationType"=>'3'} # count of ?subject
      ] }
      let (:conditions) { LodViewRewrite::Condition.new( cond.to_json ) }

      it 'generates SPARQL query correctly' do
        expected =<<EOQ
SELECT (COUNT(?subject) AS ?count_subject)
WHERE {
  ?subject <http://dbpedia.org/property/prefecture> <http://dbpedia.org/resource/Tokyo> .
  FILTER (str(?subject) = \"http://dbpedia.org/resource/Minato,_Tokyo\")
}
LIMIT 1000
EOQ
        @query.to_sparql( conditions ).should eq expected.strip!
      end

      it 'can execute to DBpedia.org' do
        expected_var_name = /count_subject/
        expected_count = /1/
        result = JSON.parse( @query.exec_sparql( conditions ) ).to_s
        expect( result ).to match( expected_var_name )
        expect( result ).to match( expected_count )
      end
    end
  end

end
