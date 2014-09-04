require_relative 'helper'

describe WishETL::Step do
  class SimplePipeTransform
    include WishETL::Tube::Pipe
    include WishETL::Step::Base

    def transform
      @datum.transformed = @datum.input.reverse
    end
  end

  class MultiRowStartPoint
    include WishETL::Tube::Pipe
    include WishETL::Step::MultiRowBegin

    def prep_array
      @array = @datum.input['racedata']
    end
  end

  class MultiRowEndPoint
    include WishETL::Tube::Pipe
    include WishETL::Step::MultiRowEnd

    def transform
      input = @current[0].meta['original']
      @current.each_with_index { |item, index|
        input['racedata'][index] = item.input
      }
      @datum.transformed = input
    end
  end

  context "MultiRow split/join" do
    Given (:runner) { WishETL::Runner.instance }
    Given (:step1) { MultiRowStartPoint.new }
    Given (:step2) { SimplePipeTransform.new(:parent => step1) }
    Given! (:step3) { MultiRowEndPoint.new(:parent => step2) }

    When {
      rd, wr = ::IO.pipe
      wr.puts MultiJson.dump({ 'input' => {'racedata' => [ 'abc', 'def' ] } })
      step1.attach_from rd
      runner.run(false)
    }

    Then { step3.datum.transformed == {'racedata' => [ 'cba', 'fed' ] } }
  end
end
