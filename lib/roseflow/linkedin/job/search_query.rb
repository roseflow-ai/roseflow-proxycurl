# frozen_string_literal: true

require "dry-validation"
require "roseflow/proxycurl/object"
require "roseflow/linkedin/job"
require "roseflow/types"

module Roseflow
  module LinkedIn
    class Job
      class SearchQuery < Proxycurl::ProxycurlObject
        class SearchQueryContract < Dry::Validation::Contract
          params do
            optional(:keyword).filled(:string)
            optional(:geo_id).filled(:integer)
            optional(:search_id).filled(:string)
            optional(:flexibility).filled(:string)
            optional(:experience_level).filled(:string)
            optional(:job_type).filled(:string)
            optional(:when).filled(:string)
          end
        end

        contract_object SearchQueryContract

        schema schema.strict

        attribute? :keyword, Types::String
        attribute? :geo_id, Types::Integer.default(92000000)
        attribute? :search_id, Types::String
        attribute? :flexibility, Types::String.default("anything")
        attribute? :experience_level, Types::String.default("anything")
        attribute? :job_type, Types::String.default("anything")
        attribute? :when, Types::String.default("anytime")

        def self.new(input)
          validation = self.contract_object.new.call(input)
          raise ArgumentError, validation.errors.to_h.inspect unless validation.success?
          super(input)
        end

        def to_request_params
          to_h
        end
      end
    end
  end
end
