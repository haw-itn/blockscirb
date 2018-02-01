require 'spec_helper'

RSpec.describe BlockSci::Parser::ChainIndex do

  describe '#max_block_file_num' do
    subject {BlockSci::Parser::ChainIndex.new(test_configuration)}
    it 'should return existing block file count' do
      expect(subject.send(:max_block_file_num, 0)).to eq(0)
    end
  end

  describe '#update' do
    context 'load file' do
      subject {
        index = BlockSci::Parser::ChainIndex.new(test_configuration)
        index.update
        index
      }
      it 'should parse block' do
        expect(subject.newest_block.block_hash).to eq('281dcd1e9124deef18140b754eab0550c46d6bd55e815415266c89d8faaf1f2d')
        expect(subject.newest_block.tx_count).to eq(4)
        expect(subject.newest_block.input_count).to eq(3) # not count coinbase
        expect(subject.newest_block.output_count).to eq(8)
        expect(subject.newest_block.size).to eq(870)
        expect(subject.newest_block.file_num).to eq(0)
        expect(subject.newest_block.height).to eq(102)
        expect(subject.newest_block.header.to_payload.bth).to eq('000000209986299405bf4e5e9964a3baf8e0373fc44d8dfdc7acea198dc1e48445bd083c54da248b4ebfaee36446a981034f3e3e1ae3298c07b793d5e51b5d6c47dea947e29f725affff7f2000000000')
      end
    end

  end

end
