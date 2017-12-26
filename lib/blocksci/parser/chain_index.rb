module BlockSci
  module Parser
    class ChainIndex

      attr_reader :configuration
      attr_accessor :block_list
      attr_accessor :newest_block

      def initialize(configuration)
        @configuration = configuration
        @block_list = {}
      end

      def update
        file_num = 0
        file_pos = 0
        unless block_list.empty?
          # TODO
        end

        first_file_num = file_num
        max_file_num = max_block_file_num
        file_count = max_file_num - file_num
        file_done = 0
        valid_magic_head = Bitcoin.chain_params.magic_head
        blocks = []

        file_count.times do
          puts 'fetch block start.'
          File.open(configuration.path_for_block_file(file_num)) do |f|
            io = StringIO.new(f.read)
            io.pos = file_pos if first_file_num == file_num && file_pos > 0
            until io.eof?
              current_block_pos = io.pos
              magic_head, size = io.read(8).unpack("a4I")
              raise 'magic bytes is mismatch.' unless magic_head.bth == valid_magic_head
              block = BlockSci::Parser::BlockInfo.parse_from_raw_data(io, size, file_num, current_block_pos)
              @block_list[block.hash] = block
              blocks << block
            end
          end
          file_done += 1
          file_num += 1
          print "\r#{((file_done.to_f / file_count) * 100).to_i}% done fetching block."
          @newest_block = blocks.last if file_num == max_file_num && !blocks.empty?
        end
        puts
      end


      private

      def max_block_file_num(start_file = 0)
        file_num = start_file
        while File.exist?(configuration.path_for_block_file(file_num))
          file_num += 1
        end
        file_num
      end

    end
  end
end
