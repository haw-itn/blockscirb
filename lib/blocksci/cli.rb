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
      data_configuration = BlockSci::Util::DataConfiguration.new(File.expand_path(options[:output_directory]))
      starting_tx_count = get_starting_tx_count(data_configuration)
      max_block_height = chain_blocks.newest_block.height

      total_tx_count = 0
      total_input_count = 0
      total_output_count = 0
      chain_blocks.block_list.each do |(k, block)|
        total_tx_count += block.tx_count
        total_input_count += block.input_count
        total_output_count += block.output_count
      end
      
    end

    private
    def get_starting_tx_count(config)
      return 0
    end
  end
end
