#Runner
require_relative 'helper'
require_relative '../lib/wishETL/tube/pg.rb'

require 'pg'

pg = PGHelper.new
pg.exec_simple "DROP TABLE IF EXISTS rspec.test"
pg.exec_simple "CREATE TABLE rspec.test (id SERIAL, data TEXT)"

describe WishETL::Step do
  class SimplePostgreSQLLoader
    include WishETL::Tube::StringIn
    include WishETL::Tube::NullOut
    include WishETL::Tube::PgLoader
    include WishETL::Step::Base

    def transform
      super
      @datum.meta['input'] = @datum.transformed
    end

    def load
      @conn.exec_simple "INSERT INTO rspec.test (data) VALUES ($1::TEXT)", @datum.transformed
    end
  end

  context "PostgreSQL Loader" do
    Given (:runner) { WishETL::Runner.instance }
    Given (:step) { SimplePostgreSQLLoader.new }
    When {
      step.attach_from ('a'..'z').to_a.shuffle[0,8].join
      runner.run(false)
    }
    Then { pg.exec("SELECT data FROM rspec.test").values[0][0] == step.datum.meta['input'] }
  end
end
