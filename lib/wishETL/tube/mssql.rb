require 'tiny_tds'

class MSSQLHelper
  attr_reader :res

  def initialize(opts = {})
    ENV['MSSQLPORT'] ||= '1433'
    @conn = TinyTds::Client.new(:username => ENV['MSSQLUSER'], :password => ENV['MSSQLPASS'], :host => ENV['MSSQLHOST'], :port => ENV['MSSQLPORT'], :timeout => 60000)
  end

  def exec(sql)
    @res = @conn.execute(sql)
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
