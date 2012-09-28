module Tire
  class InvalidAsOptionException < Exception

    def initialize( value )
      super("Unknown type for :as field, accepted types are `Symbol`, `String`, `lambda`s and `Proc`s - #{value.class.name} - #{value.inspect}")
    end

  end
end
