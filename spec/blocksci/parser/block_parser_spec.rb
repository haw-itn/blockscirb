require 'spec_helper'

RSpec.describe BlockSci::Parser::BlockParser do
  describe '#generate_chain' do
    context 'after load file' do
      subject {
        index = BlockSci::Parser::ChainIndex.new(test_configuration)
        index.update
        index
      }
      it 'should load file' do
        blocks = subject.generate_chain(0)
        expect(blocks[-1].block_hash).to eq '281dcd1e9124deef18140b754eab0550c46d6bd55e815415266c89d8faaf1f2d'
        expect(blocks[-1].tx_count).to eq(4)
        expect(blocks[-1].input_count).to eq(3) # not count coinbase
        expect(blocks[-1].output_count).to eq(8)
        expect(blocks[-1].size).to eq(870)
        expect(blocks[-1].file_num).to eq(0)
        expect(blocks[-1].height).to eq(102)
        expect(blocks[-1].header.to_payload.bth).to eq('000000209986299405bf4e5e9964a3baf8e0373fc44d8dfdc7acea198dc1e48445bd083c54da248b4ebfaee36446a981034f3e3e1ae3298c07b793d5e51b5d6c47dea947e29f725affff7f2000000000')
      end
    end
  end

  describe 'get_starting_tx_count' do
    subject {
      config = BlockSci::Util::DataConfiguration.new("#{Dir.tmpdir}/spec")
      parser = BlockSci::Parser::BlockParser.new(config)
      parser.send(:get_starting_tx_count, config)
    }


    it 'should return 0' do
      expect(subject).to eq 0
    end

  end
end
