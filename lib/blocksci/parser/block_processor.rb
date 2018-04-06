module BlockSci
  module Parser
    class BlockProcessor
      attr_accessor :starting_tx_count
      attr_accessor :current_tx_num
      attr_accessor :total_tx_count
      attr_accessor :max_block_height

      def initialize(starting_tx_count, total_tx_count, max_block_height)
        @starting_tx_count = starting_tx_count
        @current_tx_num = starting_tx_count
        @total_tx_count = total_tx_count
        @max_block_height = max_block_height
      end


      def add_new_blocks(config, blocks)
        reader = importer(config, blocks)
      end

      private
      def importer(config, blocks)
        file_reader = BlockSci::Parser::BlockFileReader.new(config, blocks, current_tx_num)
        files = BlockSci::Parser::NewBlocksFiles.new(config)

        blocks.each do |block|
          file_reader.next_block(block, current_tx_num)
          read_new_block(current_tx_num, block, file_reader, files)
          @current_tx_num += block.tx_count
        end
        file_reader
      end

      def read_new_block(firts_tx_num, block, file_reader, files)
        coinbase = []
        is_segwit = false
        null_hash = nil
        header_size = 80 + varialbe_length_int_size(block.tx_count)
        base_size = header_size
        real_size = header_size
        block.tx_count.times do |i|
          # calculate transactions func
        end
        raw_block = BlockSci::Chain::RawBlock.new(firts_tx_num, block.tx_count, block.height, block.block_hash, block.header.version, block.header.time, block.header.bits, block.header.nonce, real_size, base_size, 0)
        firts_tx_num += block.tx_count
        files.block_file.write(raw_block)

        return coinbase
      end

      def load_finished_tx(tx)
      end

      def varialbe_length_int_size(n)
        if n < 253
          return 1
        elsif n <= 65535
          return 3
        elsif n <= 4294967295
          return 5
        else
          return 9
        end
      end

    end

    class BlockFileReader
      attr_accessor :files
      attr_accessor :last_tx_required
      attr_reader :config

      attr_accessor :current_height
      attr_accessor :current_tx_num

      MAGIC_BYTE = 8
      BLOCK_HEADER_SIZE = 80

      def initialize(config, blocks_to_add, first_tx_num)
        @last_tx_required = {}
        @files = []
        @config = config
        blocks_to_add.each do |b|
          @first_tx_num = (first_tx_num += b.tx_count)
          @last_tx_required[b.file_num] = @first_tx_num
        end
      end

      def next_block(block, first_tx_num)
        file_it = files.assoc(block.file_num)
        if file_it.nil?
          block_path = config.path_for_block_file(block.file_num)
          raise ("Error: Failed to open block file " + block_path) unless File.exist?(block_path)
          files << [block.file_num, [block_path, last_tx_required[block.file_num]]]
        end
        File.open(files.assoc(block.file_num)[1][0]) do |f|
          file_pos = f.pos + block.file_pos
          io = StringIO.new(f.read)
          io.seek(0, IO::SEEK_END)
          if (BLOCK_HEADER_SIZE + MAGIC_BYTE) <= (io.pos - file_pos)
            io.pos = file_pos
            io.pos += BLOCK_HEADER_SIZE + MAGIC_BYTE
          else
            raise 'Tried to advance past end of file'
          end
        end
        @current_height = block.height
        @current_tx_num = first_tx_num
      end

      def back_update_txes(config)
        link_data_file = config.tx_updates_file_path

        puts "Back linking transactions"

        updates = []
        File.open(link_data_file) do |f|
          updates << f.read(1)
        end
        updates.each_with_index do |update, i|

        end

        File.delete(config.tx_updates_file_path + ".dat")
      end

      def parse_from_raw_data(buf, size, file_num, file_pos)
        header = Bitcoin::BlockHeader.parse_from_payload(buf.read(80))
        tx_in = tx_out = 0
        tx_count = Bitcoin.unpack_var_int_from_io(buf)
        tx_count.times do
          in_count, out_count = parse_tx_header(buf)
          tx_in += in_count
          tx_out += out_count
        end
        tx_in -= 1 # remove coinbase
        self.new(header, size, tx_count, tx_in, tx_out, file_num, file_pos)
      end

      def parse_tx_header(buf)
        ver = buf.read(4) # version

        in_count = Bitcoin.unpack_var_int_from_io(buf)
        witness = false
        if in_count.zero?
          flag = buf.read(1).unpack('c').first
          if flag.zero?
            buf.pos -= 1
          else
            in_count = Bitcoin.unpack_var_int_from_io(buf)
            witness = true
          end
        end

        hash = buf.read(32)
        buf.read(4) # previous txout-index
        in_count.times do |i|
          sig_length = Bitcoin.unpack_var_int_from_io(buf)
          if (i + 1) < in_count
            buf.read(sig_length + 4 + 36)
          else
            buf.read(sig_length + 4)
          end
        end

        out_count = Bitcoin.unpack_var_int_from_io(buf)
        buf.read(8)
        out_count.times do |i|
          script_size = Bitcoin.unpack_var_int_from_io(buf)
          if (i + 1) < out_count
            buf.read(script_size + 8)
          else
            buf.read(script_size)
          end
        end

        if witness
          in_count.times do
            witness_count = Bitcoin.unpack_var_int_from_io(buf)
            witness_count.times do
              buf.read(Bitcoin.unpack_var_int_from_io(buf))
            end
          end
        end

        locktime = buf.read(4) # lock_time

        [ver, hash, in_count, out_count, locktime]
      end

    end

    class NewBlocksFiles
      attr_accessor :block_coinbase_file
      attr_accessor :block_file
      attr_accessor :sequence_file

      def initialize(config)
        @block_coinbase_file = config.block_coinbase_file_path
        @block_file = BlockSci::Util::FixedSizeFileMapper.new(config.block_file_path)
        @sequence_file = config.sequence_file_path
      end

      def write_to_file(inputs)
        File.open(sequence_file + "_index.dat", 'a') do |f|
          inputs.each do |arr|
            f.write(arr[-1])
            f.flush
          end
          puts
        end
      end
    end
  end
end