module WishETL
  module Tube
    module Base
      include WishETL::Base

      attr_accessor :datum, :meta, :output
      attr_reader :input

      def initialize(opts = {})
        super
      end

      def attach_from(input)
        @input = input
        @enumerator = @input.to_enum
      end

      def attach_to(next_step)
        @next_step = next_step
      end

      def cleanup
      end

      def extract
        begin
          val = @enumerator.next_values
          prep_datum val[0]
          true
        rescue
          cleanup
          false
        end
      end

      def load
        @output.puts MultiJson.dump({
                                     "input" => @datum.transformed,
                                     "meta" => @datum.meta
                                    })
      end

      def prep_datum(data)
        hash = MultiJson.load(data)
        @datum.input = hash["input"]
        @datum.meta = hash["meta"]
      end
    end
  end
end
