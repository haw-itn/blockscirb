require 'spec_helper'

RSpec.describe BlockSci::CLI do

  describe 'get_starting_tx_count' do
    subject {
      cli = BlockSci::CLI.new
      config = BlockSci::Util::DataConfiguration.new("#{Dir.tmpdir}/spec")
      cli.send(:get_starting_tx_count, config)
    }


    it 'should return 0' do
      expect(subject).to eq 0
    end

  end

end
