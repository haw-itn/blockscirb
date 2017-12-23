require 'spec_helper'

RSpec.describe BlockSci::Parser::Configuration do

  describe 'load coin network' do
    context 'mainnet' do
      before { BlockSci::Parser::Configuration.new(Dir.tmpdir, '~/.bitcoin') }
      it 'should load mainnet' do
        expect(Bitcoin.chain_params.mainnet?).to be true
      end
    end

    context 'testnet' do
      before { BlockSci::Parser::Configuration.new(Dir.tmpdir, '~/.bitcoin/testnet3') }
      it 'should load testnet' do
        expect(Bitcoin.chain_params.testnet?).to be true
      end
    end

    context 'regtest' do
      before { BlockSci::Parser::Configuration.new(Dir.tmpdir, '~/.bitcoin/regtest') }
      it 'should load regtest' do
        expect(Bitcoin.chain_params.regtest?).to be true
      end
    end
  end

end