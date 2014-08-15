require_relative 'helper'
require 'rspec/given'
require 'rspec/its'

describe WishETL::Step do
  class SimpleStep
    include WishETL::Tube::String
    include WishETL::Step::Base
  end

  class SimpleStep2 < SimpleStep
  end

  context "Simple step" do
    test_input = 'Testing'

    Given (:step) { SimpleStep.new }
    When { step.attach_from test_input }

    context "Default operations" do
      context "Extract" do
        When { step.extract }
        Then { step.datum.input == test_input }

        context "Transform" do
          When { step.transform }
          Then { step.datum.transformed == step.datum.input }
        end
      end
    end

    context "Connect a pair together" do
      Given (:step1) { SimpleStep.new }
      Given (:step2) { SimpleStep2.new }

      When {
        step1.attach_to step2
        step1.attach_from 'Bob'
        step1.etl
        step2.extract
      }

      context "Load/Extract" do
        Then { step2.datum.input == step1.datum.transformed }
      end
    end
  end
end
