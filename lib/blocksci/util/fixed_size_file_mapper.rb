module BlockSci
  module Util
    class FixedSizeFileMapper

      attr_reader :data_file
      attr_accessor :file_end

      UNITSIZE = 76

      def initialize(path)
        @data_file = path + ".dat"
        unless File.exists?(data_file)
          File.open(data_file, "w"){}
        end
        @file_end = File.size(data_file)
      end

      def size
        # return block height by calculate byte size
        file_end / UNITSIZE
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

      def write(block)
        File.open(data_file, "a") do |f|
          f.write(block.to_payload)
        end
      end
    end
  end
end
