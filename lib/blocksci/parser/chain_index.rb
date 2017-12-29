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

        max_file_num = max_block_file_num
        file_count = max_file_num - file_num
        file_done = 0
        valid_magic_head = Bitcoin.chain_params.magic_head.htb
        blocks = []

        files = []
        file_count.times do |i|
          files << configuration.path_for_block_file(file_num + i)
        end

        puts 'fetch block start.'
        result = Parallel.map(files, in_processes: 4, finish: -> (item, i, result){
          file_done += 1
          print "\r#{((file_done.to_f / file_count) * 100).to_i}% done fetching block."
        }) do |file|
          File.open(file) do |f|
            first_file = file == files.first
            last_file = file == files.last
            io = StringIO.new(f.read)
            io.pos = file_pos if first_file && file_pos > 0
            until io.eof?
              current_block_pos = io.pos
              magic_head, size = io.read(8).unpack("a4I")
              unless magic_head == valid_magic_head
                break if last_file && current_block_pos > 0
                raise 'magic bytes is mismatch.'
              end
              block = BlockSci::Parser::BlockInfo.parse_from_raw_data(io, size, to_file_num(file), current_block_pos)
              @block_list[block.hash] = block
              blocks << block
            end
            blocks.last if last_file && !blocks.empty?
          end
        end
        @newest_block = result.compact.first

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

      def to_file_num(file_name)
        num = file_name.slice(file_name.index('blk') + 3, 5)
        num.to_i if num
      end

    end
  end
end
