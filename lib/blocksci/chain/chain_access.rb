module BlockSci
  module Chain
    class ChainAccess

      attr_accessor :block_file
      attr_accessor :max_height
      attr_accessor :last_block_hash
      attr_accessor :last_block_hash_disk
      attr_accessor :max_loaded_tx
      attr_accessor :blocks_ignored

      def initialize(config)
        @block_file = BlockSci::Util::FixedSizeFileMapper.new(config.block_file_path)
        @blocks_ignored = config.blocks_ignored
        _setup
      end

      def _setup
        @max_height = block_file.size - blocks_ignored
        if max_height > 0
          max_loaded_block = block_file.get_data(max_height - 1)
          @last_block_hash = max_loaded_block.hash
          @max_loaded_tx = max_loaded_block.first_tx_index + max_loaded_block.num_txes
          @last_block_hash_disk = max_loaded_block.hash
        else
          @max_loaded_tx = 0
        end
      end

      def block_count
        max_height
      end

      def get_block(block_height)
        block_file.get_data(block_height)
      end

    end
  end
end