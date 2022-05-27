module Boundary
  class ValidationError < Boundary::Error
    attr_reader :errors

    def initialize(errors)
      super "VALIDATION_ERROR"
      @errors = errors
    end
  end
end
