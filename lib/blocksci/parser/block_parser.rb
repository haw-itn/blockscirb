module BlockSci

  module Parser

    class BlockParser

      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def update_chain
        chain_index = BlockSci::Parser::ChainIndex.new(configuration)
        chain_index.update
        chain_index.write_to_file
      end

    end

  end

end
