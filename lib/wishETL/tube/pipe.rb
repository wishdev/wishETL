module WishETL
  module Tube
    module PipeIn
      include Base
    end

    module PipeOut
      include Base

      def attach_to(next_step)
        rd, wr = ::IO.pipe
        next_step.attach_from rd
        @output = wr
      end
    end

    module Pipe
      include PipeIn
      include PipeOut
    end
  end
end
