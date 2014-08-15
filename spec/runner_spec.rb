require_relative 'helper'

describe WishETL::Step do
  class StringPipeStep
    include WishETL::Tube::StringIn
    include WishETL::Tube::PipeOut
    include WishETL::Step::Base
  end

  class PipeStep
    include WishETL::Tube::PipeIn
    include WishETL::Tube::NullOut
    include WishETL::Step::Base

    attr_writer :output_file

    def forked
      a = @output_file
      @output_file = nil
      super
      @output_file = a
    end

# :nocov:
    def load
      @output_file.puts @datum.transformed
    end
# :nocov:
  end

  class Runner
    include WishETL::Runner
  end

  context "Pipe" do
    context "Connect a pair together" do
      Given (:runner) { Runner.new }
      Given (:step1) { StringPipeStep.new }
      Given (:step2) { PipeStep.new }
      Given (:x) { Tempfile.new('rspec') }

      When {
        step2.output_file = x
        step1.attach_from 'it worked!'
        runner.steps = [step1, step2]
        runner.attach_all
        runner.run
        x.rewind
      }

      Then { x.read.strip == 'it worked!' }
    end
  end
end
