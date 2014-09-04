require_relative 'helper'

describe WishETL::Step do
  class ChooserStep
    include WishETL::Tube::Pipe
    include WishETL::Step::MultiChoice
  end

  class TwoStep
    include WishETL::Tube::Pipe
    include WishETL::Step::Base

    def accept?(datum)
      datum == '2'
    end

    def transform
      @datum.transformed = @datum.input * 2
    end
  end

  class ThreeStep
    include WishETL::Tube::Pipe
    include WishETL::Step::Base

    def accept?(datum)
      datum == '3'
    end
  end

  class MultiInputStep
    include WishETL::Tube::PipeIn
    include WishETL::Tube::NullOut
    include WishETL::Step::MultiInput

#    def initialize(*args)
#      super
#    end

    def transform
      if @tmp
        @datum.transformed = @tmp ** @datum.input.to_i
        @tmp = nil
      else
        @tmp = @datum.input.to_i
      end
    end
  end

  context "MultiChoice split/join" do
    Given (:runner) { WishETL::Runner.instance }
    Given! (:step1) { ChooserStep.new }
    Given! (:step2) { TwoStep.new(:parent => step1) }
    Given! (:step3) { ThreeStep.new(:parent => step1) }
    Given! (:step4) { MultiInputStep.new(:parent => step1) }

    context "Connect everything together" do
      context "2 then 3" do
        When {
          data = StringIO.new
          data.puts '2'
          data.puts '3'
          step1.attach_from data
          runner.run
        }

        Then { step4.datum.transformed == 10648 }
      end

      context "3 then 2" do
        When {
          data = StringIO.new
          data.puts '3'
          data.puts '2'
          step1.attach_from data
          runner.run
        }

        Then { step4.datum.transformed == 31381059609 }
      end
    end
  end
end
