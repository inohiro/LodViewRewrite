# coding: utf-8

require 'spec_helper'
require 'json'

describe LodViewRewrite::Condition do

  context 'no conditions' do
    before :each do
      @conditions = LodViewRewrite::Condition.new( [].to_json )
    end

    it 'select will be empty' do
      expect(@conditions.select).to eq ""
      expect(@conditions.select.class).to eq(String)
    end

    it 'filters will be empty' do
      expect(@conditions.filters).to be_empty
      expect(@conditions.filters.class).to eq(Array)
    end
  end

  describe 'with simple filter' do
    describe 'numerical filter condition' do
      context 'operator is Equal' do
        before :each do
          cond = [ {"FilterType"=>3, "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>"="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          expect(@conditions.filters).to eq(["FILTER (?age = 30"])
        end
      end

      context 'operator is GreaterThan' do
        before :each do
          cond = [ {"FilterType"=>3, "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>">"} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          expect(@conditions.filters).to eq(["FILTER (?age > 30)"])
        end
      end

      context 'operator is SmallerThan' do
        before :each do
          cond = [ {"FilterType"=>3, "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>"<"} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          expect(@conditions.filters).to eq(["FILTER (?age < 30)"])
        end
      end

      context 'operator is GreaterThanOrEqual' do
        before :each do
          cond = [ {"FilterType"=>3, "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>">="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          expect(@conditions.filters).to eq(["FILTER (?age >= 30)"])
        end
      end

      context 'operator is SmallerThanOrEqual' do
        before :each do
          cond = [ {"FilterType"=>3, "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>"<="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          expect(@conditions.filters).to eq(["FILTER (?age <= 30)"])
        end
      end
    end

    describe 'string condition' do

      context 'operator is Equal' do
        before :each do
          cond = [ {"FilterType"=>3, "ConditionType"=>"System.String", "Variable"=>"name", "Condition"=>"inohiro", "Operator"=>"="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          expect(@conditions.filters).to eq(["FILTER (str(?name) = \"inohiro\""])
        end
      end

      context 'operator is NotEqual' do
        before :each do
          cond = [ {"FilterType"=>3, "ConditionType"=>"System.String", "Variable"=>"name", "Condition"=>"inohiro", "Operator"=>"!="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          expect(@conditions.filters).to eq(["FILTER (str(?name) != \"inohiro\")"])
        end
      end

    end
  end

  describe 'with simple selection' do

    context 'SingleSelection with no condition' do
      before :each do
        cond = [ {"SelectionType"=>0, "Variable"=>"name"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse SingleSelection condition' do
        expect(@conditions.select).to eq("SELECT ?name")
      end
    end

    context 'SingleSelection with numerical condition' do
      before :each do
        cond = [ {"SelectionType"=>0, "Variable"=>"age", "Operator"=>"=", "Condition"=>"30", "ConditionType"=>"System.Int32"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse SingleSelection condition' do
        expect(@conditions.select).to eq("SELECT ?age")
      end

      it 'can parse filter condition' do
        expect(@conditions.filters).to eq(["FILTER (?age = 30)"])
      end
    end

    context 'SingleSelection with string condition' do
      before :each do
        cond = [ {"SelectionType"=>0, "Variable"=>"name", "Operator"=>"=", "Condition"=>"inohiro", "ConditionType"=>"System.String"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse SingleSelection condition' do
        expect(@conditions.select).to eq("SELECT ?name")
      end

      it 'can parse filter condition' do
        expect(@conditions.filters).to eq(["FILTER (str(?name) = \"inohiro\")"])
      end
    end

    context 'MultipleSelection' do
      before :each do
        cond = [ {'SelectionType'=>1, 'Variables'=> [
              {'SelectionType'=>0, 'Variable'=>'name'},
              {'SelectionType'=>0, 'Variable'=>'age'}
            ]}]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse MultipleSelection conditions' do
        expect(@conditions.select).to eq("SELECT ?name ?age")
      end
    end

    context 'All Selection' do
      before :each do
        cond = [ {'SelectionType'=>2} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse All Selection condition' do
        expect(@conditions.select).to eq("SELECT *")
      end
    end

  end

  describe 'with simple aggregation' do
    describe 'Min' do
      before :each do
        cond = [ {"AggregationType"=>0, "Variable"=>"age"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Min aggregation condition' do
        expect(@conditions.select).to eq("SELECT (MIN(?age) AS ?min_age)")
      end
    end

    describe 'Max' do
      before :each do
        cond = [ {"AggregationType"=>1, "Variable"=>"age"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Max aggregation condition' do
        expect(@conditions.select).to eq("SELECT (MAX(?age) AS ?max_age)")
      end
    end

    describe 'Sum' do
      before :each do
        cond = [ {"AggregationType"=>2, "Variable"=>"age"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Sum aggregation condition' do
        expect(@conditions.select).to eq("SELECT (SUM(?age) AS ?sum_age)")
      end
    end

    describe 'Count' do
      before :each do
        cond = [ {"AggregationType"=>3, "Variable"=>"name"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Count aggregation condition' do
        expect(@conditions.select).to eq("SELECT (COUNT(?name) AS ?count_name)")
      end
    end

    describe 'Average' do
      before :each do
        cond = [ {"AggregationType"=>4, "Variable"=>"age"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Average aggregation condition' do
        expect(@conditions.select).to eq("SELECT (AVG(?age) AS ?avg_age)")
      end
    end
  end

  describe 'with complex input,' do
    before :each do
      cond = [
        {"SelectionType"=>1, "Variables"=>[
            {"Variable"=>"name", "Condition"=>"", "Operator"=>"", "SelectionType"=>0},
            {"Variable"=>"age", "Condition"=>"", "Operator"=>"", "SelectionType"=>0}]},
        {"Variable"=>"age", "Condition"=>"30", "Operator"=>"<=", "FilterType"=>3, "ConditionType"=>"System.Int32"} ]
      @conditions = LodViewRewrite::Condition.new( cond.to_json )
    end

    it 'can parse select closure' do
      expect(@conditions.select).to eq("SELECT ?name ?age")
    end

    it 'can parse numerical filters' do
      expect(@conditions.filters).to eq(["FILTER (?age <= 30)"])
    end
  end

  describe 'with aggregation conditions,' do
    before :each do
      cond = [
        {"Variable"=>"name", "Condition"=>"inohiro", "Operator"=>"=", "FilterType"=>3,"ConditionType"=>"System.String"},
        {"Variable"=>"age", "AggregationType"=>4}]
      @conditions = LodViewRewrite::Condition.new( cond.to_json )
    end

    it 'can parse select closure' do
      expect(@conditions.select).to eq("SELECT (AVG(?age) AS ?avg_age)")
    end

    it 'can parse string filters' do
      expect(@conditions.filters).to eq(['FILTER (str(?name) = "inohiro")'])
    end
  end

  describe 'support ORDER BY' do

    context 'ORDER BY' do
      let (:cond) { [
          {"Variable"=>"name", "Condition"=>"inohiro", "Operator"=>"=", "FilterType"=>3,"ConditionType"=>"System.String"},
          {"Variable"=>"age", "AggregationType"=>6} ] }
      let (:conditions) { LodViewRewrite::Condition.new( cond.to_json ) }

      it 'can parse correctly' do
        expect( conditions.orderby ).to eq "ORDER BY ?age"
      end
    end

    context 'ORDER BY Descending' do
      let (:cond) { [
          {"Variable"=>"name", "Condition"=>"inohiro", "Operator"=>"=", "FilterType"=>3,"ConditionType"=>"System.String"},
          {"Variable"=>"age", "AggregationType"=>7} ] }
      let (:conditions ) { LodViewRewrite::Condition.new( cond.to_json ) }

      it 'can parse correctly' do
        expect( conditions.orderby ).to eq "ORDER BY DESC(?age)"
      end
    end
  end

  describe 'support GROUP BY' do
    context 'GROUP BY' do
      let (:cond) { [
          {"Variable"=>"name", "Condition"=>"inohiro", "Operator"=>"=", "FilterType"=>3,"ConditionType"=>"System.String"},
          {"Variable"=>"affiliation", "AggregationType"=>5} ] }
      let (:conditions ) { LodViewRewrite::Condition.new( cond.to_json ) }

      it 'can parse correctly' do
        expect( conditions.groupby ).to eq "GROUP BY ?affiliation"
      end
    end
  end

end
