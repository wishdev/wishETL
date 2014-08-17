require_relative 'helper'
require 'tempfile'

file = Tempfile.new('json')
file.puts MultiJson.dump( 'bob' )
file.close

describe WishETL::Step do
  class JSONFileName
    include WishETL::Tube::StringIn
    include WishETL::Tube::Files::JSONFileName
    include WishETL::Tube::NullOut
    include WishETL::Step::Base
  end

  context "JSON FileName" do
    Given (:step) { JSONFileName.new }
    When {
      step.attach_from file.path
      step.etl
    }
    Then { step.datum.transformed == 'bob' }
  end
end
