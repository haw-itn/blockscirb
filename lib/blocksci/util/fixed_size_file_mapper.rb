module BlockSci
  module Util
    class FixedSizeFileMapper

      attr_reader :data_file
      attr_accessor :file_end

      UNITSIZE = 80

      def initialize(config)
        @data_file = config.block_file_path + ".dat"
        @file_end = File.exists?(data_file) ? File.size(data_file) : 0
      end

      def size
        # return block height by calculate byte size
        File.size(data_file) / UNITSIZE
      end

      def get_pos(index)
        index * UNITSIZE
      end

      # block height +index+
      def get_data(index)
        payload = ''
        File.open(data_file) do |f|
          f.pos = get_pos(index)
          payload = f.read(UNITSIZE)
        end
        BlockSci::Chain::RawBlock.parse_from_payload(payload)
      end

      def truncate(index)
        File.truncate(data_file, get_pos(index))
      end
    end
  end
end