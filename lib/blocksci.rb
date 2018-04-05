require 'blocksci/version'
require 'bitcoin'
require 'parallel'

module BlockSci
  autoload :Parser, 'blocksci/parser'
  autoload :Util, 'blocksci/util'
  autoload :Chain, 'blocksci/chain'
  autoload :CLI, 'blocksci/cli'
end
