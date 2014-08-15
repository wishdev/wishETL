module WishETL
  module Runner
    attr_writer :steps

    def initialize
      @pids = []
    end

    def attach_all
      @steps.inject { |current_step, next_step|
        current_step.attach_to next_step
      }
    end

    def run
      @steps.each { |step|
        @pids << fork do
# :nocov:
          step.run
# :nocov:
        end
        step.forked
      }
      Process.waitall
    end
  end
end
