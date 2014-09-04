require 'pry'
require 'pry-stack_explorer'
require 'ap'

require 'simplecov'
SimpleCov.start

require 'rspec/given'
require 'rspec/its'

require 'wishETL'

module WishETL
  module Tube
    module Base
      alias :load_orig :load

      def load
        load_orig if @output || @opts[:force_load]
      end
    end
  end
end

RSpec.configure do |config|
  config.before(:each) {
    WishETL::Runner.instance.flush
  }
end
