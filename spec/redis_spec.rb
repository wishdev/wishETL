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
  end

  context "RedisInputQueue" do
    Given (:step) { SimpleRedisQueueStep.new }
    When {
      step.attach_to 'rspec'
      step.etl
    }
    Then { step.datum.transformed == "hello kids" }

    When { step.etl }
    Then { step.datum.transformed.nil? }
  end
end
