require "json-schema"

module Helper
  class JsonHelper
    def initialize; end

    def convert_to_ruby_hash(json_string, schema: false)
      begin
        json = JSON.parse(json_string)
      rescue JSON::ParserError => e
        raise Boundary::Json::ParseError, e.message
      end

      begin
        JSON::Validator.validate!(schema, json) if schema
      rescue JSON::Schema::ValidationError => e
        raise Boundary::Json::ValidationError.new(e.message, failed_properties: extract_failed_properties(schema:, json:))
      end

      json.deep_transform_keys { |k| k.to_s.underscore.to_sym }
    end

    def convert_to_json(hash)
      JSON.parse(hash.to_json).deep_transform_keys { |k|
        k.camelize(:lower)
      }.to_json
    end

    def extract_failed_properties(schema:, json:)
      JSON::Validator.fully_validate(schema, json).map { |message|
        message.scan(/'#\/([a-zA-Z]+)'/)
      }.flatten
    rescue StandardError
      []
    end
  end
end
