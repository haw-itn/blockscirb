module BlockSci

  module Parser

    class BlockParser

      attr_reader :configuration

      def initialize(configuration)
        @configuration = configuration
      end

      def update_chain(max_block_num)
        chain_blocks = chain_blocks(max_block_num)
        split_point = split_point(max_block_num)
        blocks_to_add = chain_blocks[0+split_point..-1]

        rollback_transactions(split_point, config)

        return if blocks_to_add.size == 0

        starting_tx_count = get_starting_tx_count(configuration)
        max_block_height = blocks_to_add[-1].height

        total_tx_count = 0
        total_input_count = 0
        total_output_count = 0
        blocks_to_add.each do |block|
          total_tx_count += block.tx_count
          total_input_count += block.input_count
          total_output_count += block.output_count
        end

        processor = BlockSci::Parser::BlockProcessor.new(starting_tx_count, total_tx_count, max_block_height)

        it = blocks_to_add[0]
        last = blocks_to_add[-1]

        while it != last do
          prev = it
          new_tx_count = 0
          it.height.upto(blocks_to_add.size-1) do |i|
            break unless new_tx_count < 10000000 && it != last
            new_tx_count += it.tx_count
            it = blocks_to_add[i+1]
          end
          next_blocks = [prev, it]
          processor.add_new_blocks(configuration, next_blocks)
        end
      end

      def rollback_transactions(block_keep_count, config)
        block_file = BlockSci::Util::FixedSizeFileMapper.new(config.block_file_path)
        block_keep_size = block_keep_count
        if block_file.size > block_keep_size
          first_deleted_block = block_file.get_data(block_keep_size)
          first_deleted_tx_num = first_deleted_block.first_tx_index

          block_file.truncate(block_keep_size)
        end
      end

      private
      def chain_blocks(max_block_num)
        chain_index = BlockSci::Parser::ChainIndex.parse_from_disk(configuration)
        latest_block = chain_index.newest_block ? chain_index.newest_block.height : 0
        chain_index.update
        blocks = chain_index.generate_chain(max_block_num)
        chain_index.write_to_file if latest_block != chain_index.newest_block.height
        blocks
      end

      def split_point(max_block_num)
        old_chain = BlockSci::Chain::ChainAccess.new(configuration)
        chain_blocks = chain_blocks(max_block_num)
        max_size = [old_chain.block_count, chain_blocks.size].min
        split_point = max_size
        max_size.times do |i|
          old_hash = old_chain.get_block(max_size - 1 - i).hash
          new_hash = chain_blocks[max_size - 1 - i].hash
          unless old_hash == new_hash
            split_point = max_size - 1 - i
            break
          end
        end
        print "Starting with chain of #{old_chain.block_count} blocks\n"
        print "Removing #{old_chain.block_count - split_point} blocks\n"
        print "Adding #{chain_blocks.size - split_point} blocks\n"

        split_point
      end

      def get_starting_tx_count(config)
        chain = BlockSci::Chain::ChainAccess.new(config)
        if chain.block_count > 0
          last_block = chain.get_block(chain.block_count - 1)
          return last_block.first_tx_index + last_block.num_txes
        else
          return 0
        end
      end
    end

  end

end
