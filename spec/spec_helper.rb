require "bundler/setup"
require "blocksci"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def test_configuration
  BlockSci::Parser::Configuration.new("#{Dir.tmpdir}/blocksci", File.join(File.dirname(__FILE__), 'fixtures/regtest'))
end

def test_data_configuration(dir)
  BlockSci::Util::DataConfiguration.new(dir)
end
