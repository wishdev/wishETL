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
    include WishETL::Tube::PipeIn
    include WishETL::Tube::NullOut
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
    Given (:step1) { MultiRowStartPoint.new }
    Given (:step2) { SimplePipeTransform.new }
    Given (:step3) { MultiRowEndPoint.new }

    When {
      rd, wr = ::IO.pipe
      wr.puts MultiJson.dump({ 'input' => {'racedata' => [ 'abc', 'def' ] } })
      step1.attach_from rd
      step1.attach_to step2
      step2.attach_to step3
      step1.etl
      step2.etl
      step2.etl
      step3.etl
      step3.etl
    }

    Then { step3.datum.transformed == {'racedata' => [ 'cba', 'fed' ] } }
  end
end
