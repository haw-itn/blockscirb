module BlockSci

  module Parser

    class BlockParser

      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def update_chain(max_block_num)
        chain_index = BlockSci::Parser::ChainIndex.parse_from_disk(configuration)
        latest_block = chain_index.newest_block ? chain_index.newest_block.height : 0
        chain_index.update
        blocks = chain_index.generate_chain(max_block_num)
        chain_index.write_to_file if latest_block != chain_index.newest_block.height
        blocks
      end

    end

  end

end
