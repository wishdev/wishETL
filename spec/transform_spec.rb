require_relative 'helper'

describe WishETL::Step do
  class SimpleTransform
    include WishETL::Tube::StringIn
    include WishETL::Tube::NullOut
    include WishETL::Step::Base

    def transform
      @datum.transformed = @datum.input.reverse
    end
  end

  context "Simple transform" do
    Given (:step) { SimpleTransform.new }

    context "Transform" do
      When {
        step.attach_from ('a'..'z').to_a.shuffle[0,8].join
        step.etl
      }
      Then { step.datum.transformed == step.datum.input.reverse }
    end
  end
end
