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
            begin
              step.run
            rescue => e
              if ENV['SENTRY_DSN']
                Raven.capture_message "Exception while running ETL", tags: { error: "ETL" }
                Raven.capture_exception e, tags: { error: "ETL" }
              end
              puts e.message
              puts e.backtrace.join("\n")
              exit 99
            end
# :nocov:
          end
          step.forked
        else
          step.run
        end
      }
      begin
        until @pids.empty?
          pid, status = Process.wait2
          @pids.delete(pid)
          if status.exitstatus != 0
            @pids.each { |pid|
              Process.kill "HUP", pid
            }
            raise "I fell over"
          end
        end
      rescue SystemCallError
      end
    end
  end
end
