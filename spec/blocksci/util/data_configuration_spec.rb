require 'spec_helper'

RSpec.describe BlockSci::Util::DataConfiguration do

  describe 'init prefix' do
    context 'dash' do
      subject{test_data_configuration("#{Dir.tmpdir}/dash")}
      it 'should set prefix for dash on member' do
        expect(subject.pubkey_prefix).to eq [76]
        expect(subject.script_prefix).to eq [16]
      end
    end

    context 'litecoin' do
      subject{test_data_configuration("#{Dir.tmpdir}/litecoin")}
      it 'should set prefix for litecoin on member' do
        expect(subject.pubkey_prefix).to eq [48]
        expect(subject.script_prefix).to eq [50]
      end
    end

    context 'zcash' do
      subject{test_data_configuration("#{Dir.tmpdir}/zcash")}
      it 'should set prefix for zcash on member' do
        expect(subject.pubkey_prefix).to eq [28, 184]
        expect(subject.script_prefix).to eq [28, 189]
      end
    end

    context 'namecoin' do
      subject{test_data_configuration("#{Dir.tmpdir}/namecoin")}
      it 'should set prefix for namecoin on member' do
        expect(subject.pubkey_prefix).to eq [52]
        expect(subject.script_prefix).to eq [13]
      end
    end

    context 'others' do
      subject{test_data_configuration("#{Dir.tmpdir}/others")}
      it 'should set prefix on member' do
        # set prefix for bitcoin in mainnet
        expect(subject.pubkey_prefix).to eq [0]
        expect(subject.script_prefix).to eq [5]
      end
    end
  end

end
