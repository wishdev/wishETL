module WishETL
  module Base
    def initialize(opts = {})
      WishETL::Runner.instance.register self

      opts[:parent].attach_to self if opts[:parent]
    end
  end
end
