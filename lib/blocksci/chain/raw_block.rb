module BlockSci
  module Chain
    class RawBlock

      attr_accessor :first_tx_index
      attr_accessor :num_txes
      attr_accessor :height
      attr_accessor :hash
      attr_accessor :version
      attr_accessor :timestamp
      attr_accessor :bits
      attr_accessor :nonce
      attr_accessor :real_size
      attr_accessor :base_size
      attr_accessor :coinbase_offset

      def initialize(first_tx_index, num_txes, height, hash, version, timestamp, bits, nonce, real_size, base_size, coinbase_offset)
        @first_tx_index = first_tx_index
        @num_txes = num_txes
        @height = height
        @hash = hash
        @version = version
        @timestamp = timestamp
        @bits = bits
        @nonce = nonce
        @real_size = real_size
        @base_size = base_size
        @coinbase_offset = coinbase_offset
      end

      def self.parse_from_payload(payload)
        io = payload.is_a?(StringIO) ? payload : StringIO.new(payload)
        first_tx_index = io.read(4).unpack('V')
        num_txes = io.read(4).unpack('V')
        height = io.read(4).unpack('V')
        hash = io.read(32).bth
        version = io.read(4).unpack('V')
        timestamp = io.read(4).unpack('V')
        bits = io.read(4).unpack('V')
        nonce = io.read(4).unpack('V')
        real_size = io.read(4).unpack('V')
        base_size = io.read(4).unpack('V')
        coinbase_offset = io.read(8).unpack('Q')

        new(first_tx_index, num_txes, height, hash, version, timestamp, bits, nonce, real_size, base_size, coinbase_offset)
      end

      def to_payload
        [first_tx_index, num_txes, height, hash, version, timestamp, bits, nonce, real_size, base_size, coinbase_offset].pack('VVVH64VVVVVVQ')
      end
    end
  end
end
