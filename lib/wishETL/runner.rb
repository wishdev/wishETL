require 'singleton'

module WishETL
  class Runner
    include Singleton

    def initialize
      @steps = []
      @pids = []
    end

    def flush
      @steps = []
      @pids = []
    end

    def register(step)
      @steps << step
    end

    def run(fork = true)
      @steps.last.output = File.open(File::NULL, "w") if @steps.last.output.nil?
      @steps.each { |step|
        if fork
          @pids << fork do
# :nocov:
            step.run
# :nocov:
          end
          step.forked
        else
          step.run
        end
      }
      Process.waitall
    end
  end
end
