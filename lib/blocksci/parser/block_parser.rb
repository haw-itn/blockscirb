module BlockSci

  module Parser

    class BlockParser

      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def update_chain
        chain_index = BlockSci::Parser::ChainIndex.parse_from_disk(configuration)
        latest_block = chain_index.newest_block ? chain_index.newest_block.height : 0
        chain_index.update
        chain_index.write_to_file if latest_block != chain_index.newest_block.height
      end

    end

  end

end
