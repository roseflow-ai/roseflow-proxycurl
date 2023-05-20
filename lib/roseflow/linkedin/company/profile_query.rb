# frozen_string_literal: true

require "dry-validation"
require "roseflow/proxycurl/object"
require "roseflow/linkedin/company"
require "roseflow/types"

module Roseflow
  module LinkedIn
    class Company
    end

    class Company::ProfileQuery < Proxycurl::ProxycurlObject
      class ProfileQueryContract < Dry::Validation::Contract
        params do
          required(:url).filled(:string)
        end

        rule (:url) do
          unless URI.parse(value).is_a?(URI::HTTP)
            key.failure("must be a valid URL")
          end

          unless value.match?(/linkedin\.com\/company\/\w+/)
            key.failure("must be a valid LinkedIn company URL")
          end
        end
      end

      contract_object ProfileQueryContract

      schema schema.strict

      attribute :url, Types::String
      attribute :resolve_numeric_id, Types::Bool.default(false)
      attribute :categories, Types::String.default("exclude")
      attribute :funding_data, Types::String.default("exclude")
      attribute :extra, Types::String.default("exclude")
      attribute :exit_data, Types::String.default("exclude")
      attribute :acquisitions, Types::String.default("exclude")
      attribute :use_cache, Types::String.default("if-present")

      def self.new(input)
        validation = self.contract_object.new.call(input)
        raise ArgumentError, validation.errors.to_h.inspect unless validation.success?
        super(input)
      end
    end
  end
end
