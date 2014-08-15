require 'pg'

class PGHelper
  def initialize
    @conn = PG::Connection.new
  end

  def exec(sql)
    @conn.exec(sql)
  end

  def exec_simple(sql, *parms)
    if parms.empty?
      @conn.exec(sql).clear
    else
      @conn.exec_params(sql, parms).clear
    end
  end
end

module WishETL
  module Tube
    module PgLoader
      include Base

      def initialize
        @conn = PGHelper.new
      end
    end
  end
end
