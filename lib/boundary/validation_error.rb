module Boundary
  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors)
      super "VALIDATION_ERROR"
      @errors = errors
    end
  end
end
