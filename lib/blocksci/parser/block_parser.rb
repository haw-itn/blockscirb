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
      end

    end

  end

end
