require_relative 'helper'

describe WishETL::Step::Broadcaster do
  class Broadcaster
    include WishETL::Tube::StringIn
    include WishETL::Tube::PipeOut
    include WishETL::Step::Broadcaster
  end

  class Receiver
    include WishETL::Tube::PipeIn
    include WishETL::Tube::NullOut
    include WishETL::Step::Base
  end

  context "Broadcast" do
    Given (:step1) { Broadcaster.new }
    Given (:step2) { Receiver.new }
    Given (:step3) { Receiver.new }

    When {
      step1.attach_to [step2, step3]
      step1.attach_from '2'
      step1.etl
      step2.etl
      step3.etl
    }

    Then { step2.datum.transformed == '2' }
    Then { step3.datum.transformed == '2' }
  end
end
