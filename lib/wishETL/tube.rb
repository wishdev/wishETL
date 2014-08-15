reject_list = 'redis.rb'

require_all Dir.glob("#{File.dirname(__FILE__)}/tube/**/*.rb").reject { |f| reject_list.include?(File.basename(f)) }
