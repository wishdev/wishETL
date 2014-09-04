require_relative 'helper'
require_relative '../lib/wishETL/tube/redis.rb'

require 'redis'

redis = Redis.new #Assumed to be using REDIS_URL via envdir or otherwise

redis.del "rspec"

redis.rpush "rspec", "hello kids"
redis.rpush "rspec", "hello kids"

redis.rpush "rspec", "exit"

describe WishETL::Step do
  class SimpleRedisQueueStep
    include WishETL::Tube::RedisQueueIn
    include WishETL::Tube::NullOut
    include WishETL::Step::Base

    attr_reader :transformed_data

    def initialize(*args)
      super
      @transformed_data = []
    end

    def transform
      super
      @transformed_data << @datum.transformed
    end
  end

  context "RedisInputQueue" do
    Given (:runner) { WishETL::Runner.instance }
    Given (:step) { SimpleRedisQueueStep.new }
    When {
      step.attach_from 'rspec'
      runner.run(false)
    }
    Then { step.transformed_data == ["hello kids"] * 2 }
  end
end
