require_relative 'helper'

describe WishETL::Step do
  class StringPipeStep
    include WishETL::Tube::StringIn
    include WishETL::Tube::PipeOut
    include WishETL::Step::Base
  end

  class PassStep
    include WishETL::Tube::Pipe
    include WishETL::Step::Base
  end

  class PipeStepRunner
    include WishETL::Tube::Pipe
    include WishETL::Step::Base

    attr_writer :output_file

    def forked
      @output_file = @output_file.tap {
        @output_file = nil
        super
      }
    end

# :nocov:
    def load
      @output_file.puts @datum.transformed
    end
# :nocov:
  end

  context "Pipe" do
    context "Connect a pair together" do
      Given (:runner) { WishETL::Runner.instance }
      Given (:step1) { StringPipeStep.new }
      Given (:step2) { PassStep.new(:parent => step1) }
      Given (:step3) { PipeStepRunner.new(:parent => step2) }
      Given (:x) { Tempfile.new('rspec') }

      When {
        step3.output_file = x
        step1.attach_from 'it worked!'
        runner.run
        x.rewind
      }

      Then { x.read.strip == 'it worked!' }
    end

    context "Allow for a null output during testing" do
      Given (:runner) { WishETL::Runner.instance }
      Given (:step1) { StringPipeStep.new }
      Given! (:step2) { PassStep.new(:parent => step1, :force_load => true) }

      When {
        step1.attach_from 'it worked!'
        runner.run
      }

# We're just testing that we get out of the call not for anything else
      Then { 1 == 1}
    end
  end
end
