module BlockSci
  module Parser
    class ConfigurationBase < BlockSci::Util::DataConfiguration

      def initialize(data_directory_)
        super(data_directory_)
        init_dir
      end

      def parser_dir
        "#{data_directory}/parser"
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
        FileUtils.mkdir_p([parser_dir])
      end

    end
  end
end
