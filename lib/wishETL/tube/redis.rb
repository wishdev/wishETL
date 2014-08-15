require 'redis'

module WishETL
  module Tube
    module RedisQueueIn
      include Base

      def initialize(*args)
        @redis = Redis.new
        super
      end

      def attach_to(queue)
        @enumerator = Enumerator.new do |enum|
          while true
            val = @redis.blpop queue, 0
            break if val[1] == 'exit'
            enum.yield MultiJson.dump({ 'input' => val[1]})
          end
        end
      end
    end
  end
end