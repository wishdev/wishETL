require 'tiny_tds'

class MSSQLHelper
  def initialize(opts = {})
    @conn = TinyTds::Client.new(:host => ENV['MSSQL_HOST'])
  end

  def exec(sql)
    @conn.execute(sql)
  end

  def exec_simple(sql, *parms)
    if parms.empty?
      @conn.execute(sql).do
#    else
#      @conn.exec_params(sql, parms).do
    end
  end
end

module WishETL
  module Tube
    module MSSQLLoader
      include Base

      def initialize(opts = {})
        @conn = MSSQLHelper.new
        super
      end
    end
  end
end
