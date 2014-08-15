require 'multi_json'

module WishETL
  module Tube
    module StringIn
      include Base

      def attach_from(string)
        super StringIO.new(MultiJson.dump({"input" => string}))
      end
    end

    module StringOut
      include Base

      def load
        @next_step.attach_from @datum.transformed
      end
    end

    module String
      include StringIn
      include StringOut
    end
  end
end
