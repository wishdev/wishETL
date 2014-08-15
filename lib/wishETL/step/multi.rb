require 'securerandom'

module WishETL
  module Step
    module MultiRowBegin
      include Base

      def etl
        extract
        @datum.meta["original"] = @datum.input

        @orig_enum = @enumerator

        prep_array

        @datum.meta["length"] = @array.length

        @enumerator = @array.to_enum

        while super
        end
        @enumerator = @orig_enum
        @orig_enum = nil
      end

      def prep_datum(data)
        if @orig_enum
          @datum.input = data
        else
          super
        end
      end

      def transform
        super
        @datum.meta["position"] = (@datum.meta["position"] || -1) + 1
        @datum.meta["uuid"] ||= SecureRandom.uuid
      end
    end

    module MultiRowEnd
      include Base
      def initialize(*args)
        super
        @arrays = Hash.new { |h,k| h[k] = Array.new }
      end

      def etl
        extract
        uuid = @datum.meta["uuid"]
        @arrays[uuid][@datum.meta["position"]] = @datum.dup
        if @arrays[uuid].length == @datum.meta["length"]
          @current = @arrays[uuid]
          transform
          load
        end
      end
    end

    module MultiChoice
      include Base
      def initialize(*args)
        super
        @outputs = []
      end

      def attach_to(*next_steps)
        next_steps = next_steps.flatten(1)
        next_steps.each { |next_step|
          rd, wr = ::IO.pipe
          if next_step.is_a? MultiInput
            @receiver = wr
            next_step.attach_from rd, true
          else
            @outputs << Choice.new(next_step, wr, @outputs.length)
            next_step.attach_from rd
          end
        }
      end

      def load
        slot = @outputs.find { |item|
          item.step.accept? @datum.transformed
        }
        @receiver.puts slot.index + 1
        @output = slot.writer
        super
      end

      class Choice
        attr_accessor :index, :step, :writer

        def initialize(step, writer, index)
          @step = step
          @writer = writer
          @index = index
        end
      end
    end

    module MultiInput
      include Base
      def initialize(*args)
        super
        @inputs = [nil]
        @slot = 0
      end

      def attach_from(new_input, chooser = false)
        if chooser
          @inputs[0] = [new_input, new_input.to_enum]
        else
          @inputs << [new_input, new_input.to_enum]
        end
      end

      def etl
        super
        @valid
      end

      def extract
        @enumerator = @inputs[@slot][1]
        @valid = super
        @valid && (@slot == 0)
      end

      def prep_datum(data)
        if @slot != 0
          @slot = 0
          super
        else
          @slot = data.strip.to_i
        end
      end
    end
  end
end
