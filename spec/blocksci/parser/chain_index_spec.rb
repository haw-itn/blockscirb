require 'spec_helper'

RSpec.describe BlockSci::Parser::ChainIndex do

  describe '#max_block_file_num' do
    subject {BlockSci::Parser::ChainIndex.new(test_configuration)}
    it 'should return existing block file count' do
      expect(subject.send(:max_block_file_num, 0)).to eq(1)
    end
  end

  describe '#update' do
    context 'load file' do
      subject {
        index = BlockSci::Parser::ChainIndex.new(test_configuration)
        allow(index).to receive(:max_block_file_num).and_return(1)
        index.update
        index
      }
      it 'should parse block' do
        expect(subject.newest_block.hash).to eq('000000002e00e366a9371454b5aef5363a298f88927e2e8a248971668ef24893')
        expect(subject.newest_block.tx_count).to eq(13)
        expect(subject.newest_block.input_count).to eq(23) # not count coinbase
        expect(subject.newest_block.output_count).to eq(28)
        expect(subject.newest_block.size).to eq(4672)
        expect(subject.newest_block.file_num).to eq(0)
        expect(subject.newest_block.header.to_payload.bth).to eq('02000000fc35cb8f9549857cc120df7682e5686e0f07265eee08a8ce42e46a39000000006ca7b08894a31985f560ac78a45a7784d4edd36851723085de1bcc31840ae4899316be51c0ff3f1cf41d5909')
      end
    end

    context 'load the part of file' do

    end
  end

end
