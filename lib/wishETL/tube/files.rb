module WishETL
  module Tube
    module Files
      module JSONFileName
        def extract
          if super
            @datum.input = MultiJson.load(File.read(@datum.input))
            true
          end
        end
      end
    end
  end
end
