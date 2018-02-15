module BlockSci
  module Parser
    class ConfigurationBase
      attr_reader :out_dir

      def initialize(out_dir)
        @out_dir = out_dir
        init_dir
      end

      def parser_dir
        "#{out_dir}/parser"
      end

      def utxo_cache_file
        "#{parser_dir}/utxoCache.dat"
      end

      def utxo_address_state_path
        "#{parser_dir}/utxoAddressState"
      end

      def utxo_script_state_path
        "#{parser_dir}/utxoScriptState"
      end

      def address_path
        "#{parser_dir}/address"
      end

      def block_list_path
        "#{parser_dir}/blockList.dat"
      end

      def tx_updates_file_path
        "#{parser_dir}/txUpdates"
      end

      private

      def init_dir
        FileUtils.mkdir_p([out_dir, parser_dir])
      end

    end
  end
end
