module BlockSci
  module Parser
    class Configuration

      attr_reader :coin_dir
      attr_reader :out_dir

      def initialize(out_dir, coin_dir)
        @out_dir = out_dir
        @coin_dir = coin_dir
        init_dir
        load_coin_network
      end

      def parser_dir

      end

      private

      def init_dir
        FileUtils.mkdir_p(out_dir) unless Dir.exist?(out_dir)
      end

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
