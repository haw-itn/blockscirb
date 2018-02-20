require 'thor'

module BlockSci
  class CLI < Thor

    desc 'update', 'Update all BlockSci data'
    option :output_directory, required: true
    option :coin_directory, required: true
    def update
      configuration = BlockSci::Parser::Configuration.new(File.expand_path(options[:output_directory]), File.expand_path(options[:coin_directory]))
      parser = BlockSci::Parser::BlockParser.new(configuration)
      chain_blocks = parser.update_chain
      starting_tx_count = get_starting_tx_count(configuration)
      max_block_height = chain_blocks.newest_block.height

      total_tx_count = 0
      total_input_count = 0
      total_output_count = 0
      chain_blocks.block_list.each do |(k, block)|
        total_tx_count += block.tx_count
        total_input_count += block.input_count
        total_output_count += block.output_count
      end

      blocks_to_add = chain_blocks.block_list.sort{|(k1, v1), (k2, v2)| v1.height <=> v2.height}.map(&:last)
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

    private
    def get_starting_tx_count(config)
      return 0
    end
  end
end
