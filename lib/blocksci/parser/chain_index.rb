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

      # parse loaded Chain Index
      def self.parse_from_disk(configuration)
        file = configuration.block_list_path
        chain_index = self.new(configuration)
        if File.exist?(file)

        end
        chain_index
      end

      def update
        file_num = 0
        file_pos = 0
        unless block_list.empty?
          # TODO
        end

        max_file_num = max_block_file_num
        # max_file_num = 1
        file_count = max_file_num - file_num + 1
        file_done = 0
        valid_magic_head = Bitcoin.chain_params.magic_head.htb
        blocks = []

        files = []
        file_count.times do |i|
          files << configuration.path_for_block_file(file_num + i)
        end

        forward_hashes = {}

        puts 'fetch block start.'
        Parallel.map(files, in_processes: 4, finish: -> (item, i, result){
          @newest_block = result.last if i == files.length - 1
          file_done += 1
          result.each do |b|
            @block_list[b.block_hash] = b
          end
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
              blocks << block
            end
            blocks
          end
        end
        puts

        @block_list.each do |h, b|
          if forward_hashes[b.header.prev_hash]
            forward_hashes[b.header.prev_hash] << h
          else
            forward_hashes[b.header.prev_hash] = [h]
          end
        end

        puts 'set block height'

        genesis_hash = Bitcoin.chain_params.genesis_block.header.hash
        block_list[genesis_hash].height = 0

        queue = [[genesis_hash, 0]]

        until queue.empty?
          block_hash, height = queue.pop
          if forward_hashes[block_hash]
            forward_hashes[block_hash].each do|next_hash|
              block = block_list[next_hash]
              block.height = height + 1
              queue << [block.block_hash, block.height]
            end
          end
        end

      end

      # write chain index to file.
      # The file is a binary file, and payload of +block_list+ and +newest_block+ are stored.
      def write_to_file
        File.open(configuration.block_list_path, 'w') do |f|
          block_list.each do |k, b|
            # next unless b.height
            f.write(b.to_payload)
            f.flush
          end
          f.write(newest_block.to_payload)
        end
      end

      private

      def max_block_file_num(start_file = 0)
        file_num = start_file
        while File.exist?(configuration.path_for_block_file(file_num))
          file_num += 1
        end
        file_num - 1
      end

      def to_file_num(file_name)
        num = file_name.slice(file_name.index('blk') + 3, 5)
        num.to_i if num
      end

    end
  end
end
