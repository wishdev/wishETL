module WishETL
  module Step
    module Base
      include WishETL::Base

      attr_accessor :datum, :output
      attr_reader :input

      def initialize(opts = {})
        @datum = WishETL::Datum.new
        @opts = opts
        super
      end

      def forked
        [@input, @output].each { |io|
          io.close if io.respond_to?(:close)
        }
      end

      def etl
        @datum.input = nil
        @datum.transformed = nil
        if extract
          transform
          load
          true
        else
          false
        end
      end

# :nocov:
      def run
        while etl
        end
        @output.close if @output.respond_to?(:close) && !@output.closed?
      end
# :nocov:

      def transform
        @datum.transformed = @datum.input
      end
    end
  end
end
