module BlockSci
  module Parser
    class Configuration < ConfigurationBase

      attr_reader :coin_dir

      def initialize(out_dir, coin_dir)
        super(out_dir)
        @coin_dir = coin_dir
        load_coin_network
      end

      def path_for_block_file(file_num)
        "#{coin_dir}/blocks/blk#{file_num.to_s.rjust(5, '0')}.dat"
      end

      private

      # change coin network from coin dirname.
      def load_coin_network
        if coin_dir.include?('testnet')
          Bitcoin.chain_params = :testnet
        elsif coin_dir.include?('regtest')
          Bitcoin.chain_params = :regtest
        else
          Bitcoin.chain_params = :mainnet
        end
      end

    end
  end
end
