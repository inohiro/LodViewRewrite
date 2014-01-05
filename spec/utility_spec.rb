# codint: utf-8

require 'spec_helper'

describe LodViewRewrite::Utility do

  describe 'Utility.set_response_format' do
    it 'detect symbol identifier correctly' do
      expect( LodViewRewrite::Utility.set_response_format :tsv ).to eq 'text/tab-separated-values'
    end

    it 'detect string identifier correctly' do
      expect( LodViewRewrite::Utility.set_response_format 'js' ).to eq 'application/json'
    end
  end

end
