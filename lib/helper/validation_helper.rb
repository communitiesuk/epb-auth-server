module Helper
  class ValidationHelper
    EMAIL = {
      message: "FIELD of 'SUBJECT' is an invalid email address",
      pattern: "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])",
    }.freeze

    NOT_EMPTY = {
      message: "FIELD cannot be empty",
      lambda: lambda do |s|
                return s.empty? if s.is_a?(Array) || s.is_a?(String)

                s.nil?
              end,
    }.freeze

    def validate(ruleset, data)
      errors = {}

      ruleset.each_key do |name|
        rules = ruleset[name]

        rules.each do |rule|
          if ValidationHelper.const_defined? rule.to_s.upcase
            validator = ValidationHelper.const_get(rule.to_s.upcase)

            if validator.key?(:pattern)
              error = validate_pattern validator, name, data[name]
              (errors[name] ||= []) << error if error
            end

            if validator.key?(:lambda)
              error = validate_lambda validator, name, data[name]
              (errors[name] ||= []) << error if error
            end
          end
        end
      end

      raise Boundary::ValidationError, errors unless errors.empty?
    end

  private

    def validate_pattern(validator, name, value)
      unless value =~ Regexp.new(validator[:pattern])
        generate_message(validator[:message], name, value)
      end
    end

    def validate_lambda(validator, name, value)
      if validator[:lambda].call(value)
        generate_message(validator[:message], name, value)
      end
    end

    def generate_message(message, name, value)
      message.gsub("FIELD", name.to_s)
             .gsub("SUBJECT", value.to_s)
    end
  end
end
