require_relative 'helper'

describe WishETL::Step do
  class StringPipeStep
    include WishETL::Tube::StringIn
    include WishETL::Tube::PipeOut
    include WishETL::Step::Base
  end

  class PipeStep
    include WishETL::Tube::Pipe
    include WishETL::Step::Base
  end

  context "Pipe" do
    Given (:step) { StringPipeStep.new }
    When { step.attach_from 'Hello' }

    context "Default operations" do
      context "Extract" do
        When { step.extract }
        Then { step.datum.input == "Hello" }

        context "Transform" do
          When { step.transform }
          Then { step.datum.transformed == "Hello" }
        end
      end
    end

    context "Connect a pair together" do
      Given (:step1) { StringPipeStep.new }
      Given (:step2) { PipeStep.new }

      When {
        step1.attach_from 'Bye'
        step1.attach_to step2
        step1.etl
        step2.extract
      }

      context "Load/Extract" do
        Then { step2.datum.input == step1.datum.transformed }
      end
    end
  end
end
