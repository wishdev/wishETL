require_relative 'helper'
require 'rspec/given'
require 'rspec/its'

describe WishETL::Step do
  test_input = ('a'..'z').to_a.shuffle[0,8].join
  result = test_input.reverse

  class SimpleStep
    include WishETL::Tube::String
    include WishETL::Step::Base

    attr_reader :test_data

    def initialize(*args)
      super
      @test_data = {}
    end

    def transform
      @datum.transformed = @datum.input.reverse
    end

    def load
      super if @next_step
      @test_data[:input] = @datum.input
      @test_data[:transformed] = @datum.transformed
    end
  end

  context "Simple step" do
    Given (:runner) { WishETL::Runner.instance }
    Given (:step) { SimpleStep.new }

    context "Default operations" do
      When {
        step.attach_from test_input
        runner.register(step)
        runner.run(false)
      }
      Then { step.test_data[:input] == test_input }
      Then { step.test_data[:transformed] == result }
    end
  end

  context "Simple connection" do
    Given (:runner) { WishETL::Runner.instance }
    Given (:step1) { SimpleStep.new }
    Given (:step2) { SimpleStep.new }

    context "Should pass string along" do
      When {
        step1.attach_from test_input
        step1.attach_to step2
        runner.run(false)
      }
      Then { step2.test_data[:input] == result }
    end
  end
end
