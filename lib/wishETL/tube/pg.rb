require 'pg'

class PGHelper
  def initialize(opts = {})
    reconnect
  end

  def reconnect
    @conn = PG::Connection.new
  end

  def exec(sql, *parms)
    begin
      if parms.empty?
        @conn.exec(sql)
      else
        @conn.exec_params(sql, parms)
      end
    rescue PG::UnableToSend
      reconnect
      retry
    end
  end

  def exec_simple(sql, *parms)
    exec(sql, *parms).clear
  end
end

module WishETL
  module Tube
    module PgLoader
      include Base

      def initialize(opts = {})
        @conn = PGHelper.new
        super
      end
    end
  end
end
