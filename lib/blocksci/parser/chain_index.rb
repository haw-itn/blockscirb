module BlockSci
  module Parser
    class ChainIndex

      attr_reader :config
      attr_accessor :block_list
      attr_accessor :newest_block
      attr_accessor :old_newest_block

      def initialize(config)
        @config = config
        @block_list = {}
      end

      # parse loaded Chain Index
      def self.parse_from_disk(config)
        file = config.block_list_path
        chain_index = self.new(config)
        if File.exist?(file)
          File.open(config.block_list_path) do |f|
            io = StringIO.new(f.read)
            size = io.size
            until io.eof?
              block_info = BlockSci::Parser::BlockInfo.parse_from_io(io)
              chain_index.block_list[block_info.block_hash] = block_info
              chain_index.newest_block = chain_index.old_newest_block = block_info if io.eof?
              print "\r#{((io.pos.to_f / size) * 100).to_i}% done load parsed block."
            end
            puts
          end
        end
        chain_index
      end

      def update
        file_num = 0
        file_pos = 0

        unless block_list.empty?
          file_num = newest_block.file_num
          file_pos = newest_block.file_pos + newest_block.size + 8 # add magic byte size
        end

        max_file_num = max_block_file_num

        file_count = max_file_num - file_num + 1
        file_done = 0
        valid_magic_head = Bitcoin.chain_params.magic_head.htb
        blocks = []

        files = []
        file_count.times do |i|
          files << config.path_for_block_file(file_num + i)
        end

        forward_hashes = {}

        puts 'fetch block start.'
        Parallel.map(files, in_processes: 4, finish: -> (item, i, result){
          @newest_block = result.last if !result.empty? && i == files.length - 1
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

        block_list.each do |h, b|
          if forward_hashes[b.header.prev_hash]
            forward_hashes[b.header.prev_hash] << h
          else
            forward_hashes[b.header.prev_hash] = [h]
          end
        end

        puts 'calculate block height.'

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

        puts "fetched blocks up to #{newest_block.height} height."
      end

      # write chain index to file.
      # The file is a binary file, and payload of +block_list+ and +newest_block+ are stored.
      def write_to_file
        File.open(config.block_list_path, 'a') do |f|
          block_count = old_newest_block ? (block_list.size - old_newest_block.height - 1) : block_list.size
          block_list = self.block_list.sort{|(k1, v1), (k2, v2)| v1.height <=> v2.height}
          block_list = block_list[(old_newest_block.height + 1)..-1] if old_newest_block
          block_list.each_with_index do |(k, b), index|
            f.write(b.to_payload)
            f.flush
            print "\r#{(((index + 1).to_f / block_count) * 100).to_i}% done write parsed block to #{config.block_list_path}."
          end
          f.write(newest_block.to_payload)
          puts
        end
      end

      def generate_chain(max_block_height)
        chain = []
        max_height = 0
        max_height_block = nil
        block_list.each do |hash, block|
          if block.height > max_height
            max_height_block = block
            max_height = block.height
          end
        end

        return chain if max_height_block.nil?

        hash = max_height_block.block_hash

        while hash != Bitcoin.chain_params.genesis_block.header.prev_hash
          block = block_list[hash]
          chain << block
          hash = Bitcoin::BlockHeader.parse_from_payload(block.header.to_payload).prev_hash
        end

        chain.reverse!
        if max_block_height < 0
          return chain[0..(chain.size-1+max_block_height)]
        elsif max_block_height == 0 || max_block_height > chain.size
          return chain
        else
          return chain[0..max_block_height]
        end
      end

      private

      def max_block_file_num(start_file = 0)
        file_num = start_file
        while File.exist?(config.path_for_block_file(file_num))
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
