# coding: utf-8

require 'spec_helper'
require 'json'

describe LodViewRewrite::Condition do

  describe 'with simple filter' do

    describe 'numerical filter condition' do
      context 'operator is Equal' do
        before :each do
          cond = [ {"FilterType"=>"3", "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>"="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          @conditions.filters.should eq [ "FILTER (?age = 30)" ]
        end
      end

      context 'operator is GreaterThan' do
        before :each do
          cond = [ {"FilterType"=>"3", "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>">"} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          @conditions.filters.should eq [ "FILTER (?age > 30)" ]
        end
      end

      context 'operator is SmallerThan' do
        before :each do
          cond = [ {"FilterType"=>"3", "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>"<"} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          @conditions.filters.should eq [ "FILTER (?age < 30)" ]
        end
      end

      context 'operator is GreaterThanOrEqual' do
        before :each do
          cond = [ {"FilterType"=>"3", "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>">="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          @conditions.filters.should eq [ "FILTER (?age >= 30)" ]
        end
      end

      context 'operator is SmallerThanOrEqual' do
        before :each do
          cond = [ {"FilterType"=>"3", "ConditionType"=>"System.Int32", "Variable"=>"age", "Condition"=>"30", "Operator"=>"<="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          @conditions.filters.should eq [ "FILTER (?age <= 30)" ]
        end
      end
    end

    describe 'string condition' do

      context 'operator is Equal' do
        before :each do
          cond = [ {"FilterType"=>"3", "ConditionType"=>"System.String", "Variable"=>"name", "Condition"=>"inohiro", "Operator"=>"="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          @conditions.filters.should eq [ "FILTER (str(?name) = \"inohiro\")" ]
        end
      end

      context 'operator is NotEqual' do
        before :each do
          cond = [ {"FilterType"=>"3", "ConditionType"=>"System.String", "Variable"=>"name", "Condition"=>"inohiro", "Operator"=>"!="} ]
          @conditions = LodViewRewrite::Condition.new( cond.to_json )
        end

        it 'can parse Equality filter' do
          @conditions.filters.should eq [ "FILTER (str(?name) != \"inohiro\")" ]
        end
      end

    end
  end

  describe 'with simple selection' do

    context 'SingleSelection with no condition' do
      before :each do
        cond = [ {"SelectionType"=>"0", "Variable"=>"name"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse SingleSelection condition' do
        @conditions.select.should eq "SELECT ?name\n"
      end
    end

    context 'SingleSelection with condition' do
      before :each do
        cond = [ {"SelectionType"=>"0", "Variable"=>"age", "Operator"=>"=", "Condition"=>"30"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse SingleSelection condition' do
        @conditions.select.should eq "SELECT ?age\n"
      end

      it 'can parse filter condition' do
        @conditions.filters.should eq [ "FILTER (?age = 30)" ]
      end

    end

    context 'MultipleSelection' do
      before :each do
        cond = [ {'SelectionType'=>'1', 'Variables'=> [
              {'SelectionType'=>'0', 'Variable'=>'name'},
              {'SelectionType'=>'0', 'Variable'=>'age'}
            ]}]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse MultipleSelection conditions' do
        @conditions.select.should eq "SELECT ?name ?age\n"
      end
    end

    context 'All Selection' do
      before :each do
        cond = [ {'SelectionType'=>'2'} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse All Selection condition' do
        @conditions.select.should eq "SELECT *\n"
      end
    end

  end

  describe 'with simple aggregation' do
    describe 'Min' do
      before :each do
        cond = [ {"AggregationType"=>"0", "Variable"=>"age"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Min aggregation condition' do
        @conditions.select.should eq "SELECT (MIN(?age) AS ?min_age)\n"
      end
    end

    describe 'Max' do
      before :each do
        cond = [ {"AggregationType"=>"1", "Variable"=>"age"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Max aggregation condition' do
        @conditions.select.should eq "SELECT (MAX(?age) AS ?max_age)\n"
      end
    end

    describe 'Sum' do
      before :each do
        cond = [ {"AggregationType"=>"2", "Variable"=>"age"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Sum aggregation condition' do
        @conditions.select.should eq "SELECT (SUM(?age) AS ?sum_age)\n"
      end
    end

    describe 'Count' do
      before :each do
        cond = [ {"AggregationType"=>"3", "Variable"=>"name"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Count aggregation condition' do
        @conditions.select.should eq "SELECT (COUNT(?name) AS ?count_name)\n"
      end
    end

    describe 'Average' do
      before :each do
        cond = [ {"AggregationType"=>"4", "Variable"=>"age"} ]
        @conditions = LodViewRewrite::Condition.new( cond.to_json )
      end

      it 'can parse Average aggregation condition' do
        @conditions.select.should eq "SELECT (AVG(?age) AS ?avg_age)\n"
      end
    end
  end

  describe 'with complex input,' do
    before :each do
      cond = [
        {"SelectionType"=>'1', "Variables"=>[
            {"Variable"=>"name", "Condition"=>"", "Operator"=>"", "SelectionType"=>'0'},
            {"Variable"=>"age", "Condition"=>"", "Operator"=>"", "SelectionType"=>'0'}]},
        {"Variable"=>"age", "Condition"=>"30", "Operator"=>"<=", "FilterType"=>'3', "ConditionType"=>"System.Int32"} ]
      @conditions = LodViewRewrite::Condition.new( cond.to_json )
    end

    it 'can parse select closure' do
      @conditions.select.should eq "SELECT ?name ?age\n"
    end

    it 'can parse numerical filters' do
      @conditions.filters.should eq ["FILTER (?age <= 30)"]
    end
  end

  describe 'with aggregation conditions,' do
    before :each do
      cond = [
        {"Variable"=>"name", "Condition"=>"inohiro", "Operator"=>"=", "FilterType"=>'3',"ConditionType"=>"System.String"},
        {"Variable"=>"age", "AggregationType"=>'4'}]
      @conditions = LodViewRewrite::Condition.new( cond.to_json )
    end

    it 'can parse select closure' do
      @conditions.select.should eq "SELECT (AVG(?age) AS ?avg_age)\n"
    end

    it 'can parse string filters' do
      @conditions.filters.should eq ['FILTER (str(?name) = "inohiro")']
    end

  end

end
