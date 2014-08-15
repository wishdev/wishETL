require_relative 'helper'

describe WishETL::Step do
  class ChooserStep
    include WishETL::Tube::StringIn
    include WishETL::Tube::PipeOut
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
    Given (:step1) { ChooserStep.new }
    Given (:step2) { TwoStep.new }
    Given (:step3) { ThreeStep.new }
    Given (:step4) { MultiInputStep.new }

    context "Connect everything together" do
      When {
        step1.attach_to [step2, step3, step4]
        step2.attach_to step4
        step3.attach_to step4
      }

      context "2 then 3" do
        When {
          step1.attach_from '2'
          step1.etl
          step1.attach_from '3'
          step1.etl
          step3.etl
          step2.etl
          step4.etl
          step4.etl
          step4.etl
          step4.etl
        }

        Then { step4.datum.transformed == 10648 }
      end

      context "3 then 2" do
        When {
          step1.attach_from '3'
          step1.etl
          step1.attach_from '2'
          step1.etl
          step3.etl
          step2.etl
          step4.etl
          step4.etl
          step4.etl
          step4.etl
        }

        Then { step4.datum.transformed == 31381059609 }
      end
    end
  end
end
