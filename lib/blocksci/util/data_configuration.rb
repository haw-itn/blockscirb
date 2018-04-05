module BlockSci
  module Util
    class DataConfiguration

      attr_accessor :error_on_reorg
      attr_accessor :blocks_ignored

      attr_reader :data_directory
      attr_reader :pubkey_prefix
      attr_reader :script_prefix

      def initialize(data_directory_)
        @error_on_reorg = false
        @blocks_ignored = 0
        @data_directory = data_directory_
        create_directory
        init_prefix
      end

      def null?
        Dir.empty?(data_directory)
      end

      def scripts_directory
        "#{data_directory}/scripts"
      end

      def chain_directory
        "#{data_directory}/chain"
      end

      def tx_file_path
        "#{chain_directory}/tx"
      end

      def tx_hashes_file_path
        "#{chain_directory}/tx_hashes"
      end

      def block_file_path
        "#{chain_directory}/block"
      end

      def block_coinbase_file_path
        "#{chain_directory}/coinbases"
      end

      def sequence_file_path
        "#{chain_directory}/sequence"
      end

      def address_db_file_path
        "#{data_directory}/addressesDb.dat"
      end

      def hash_index_file_path
        "#{data_directory}/hashIndex.dat"
      end

      def script_type_count_file
        "#{chain_directory}/scriptTypeCount.txt"
      end

      private
      def create_directory
        FileUtils.mkdir_p([data_directory, scripts_directory, chain_directory])
      end

      def init_prefix
        if data_directory.include?("dash")
          @pubkey_prefix = [76]
          @script_prefix = [16]
        elsif data_directory.include?("litecoin")
          @pubkey_prefix = [48]
          @script_prefix = [50]
        elsif data_directory.include?("zcash")
          @pubkey_prefix = [28, 184]
          @script_prefix = [28, 189]
        elsif data_directory.include?("namecoin")
          @pubkey_prefix = [52]
          @script_prefix = [13]
        else
          @pubkey_prefix = [0]
          @script_prefix = [5]
        end
      end

    end
  end
end
