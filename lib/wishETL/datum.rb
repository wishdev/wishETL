module WishETL
  class Datum
    attr_accessor :input, :meta, :transformed
    attr_writer :meta

    def meta
      @meta ||= Hash.new
    end
  end
end
