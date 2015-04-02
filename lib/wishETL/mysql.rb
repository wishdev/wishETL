require 'mysql2'

class MySQLHelper
  attr_reader :res

  def initialize(opts = {})
    @conn = Mysql2::Client.new(:username => ENV['MYSQLUSER'], :password => ENV['MYSQLPASS'], :host => ENV['MYSQLHOST'])
  end

  def exec(sql)
    @res = @conn.query(sql)
  end

  def exec_simple(sql, *parms)
    if parms.empty?
      @conn.query(sql)
#    else
#      @conn.exec_params(sql, parms).do
    end
  end
end

module WishETL
  module Tube
    module MySQLLoader
      include Base

      def initialize(opts = {})
        @conn = MySQLHelper.new
        super
      end
    end
  end
end
