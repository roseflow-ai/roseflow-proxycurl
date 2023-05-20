# frozen_string_literal: true

require "dry-validation"
require "roseflow/proxycurl/object"
require "roseflow/linkedin/company"
require "roseflow/types"

module Roseflow
  module LinkedIn
    class Company
    end

    class Company::LookupQuery < Proxycurl::ProxycurlObject
      class LookupQueryContract < Dry::Validation::Contract
        params do
          optional(:domain).filled(:string)
          optional(:name).filled(:string)
          optional(:location).filled(:string)
          optional(:enrich).filled(:bool)
        end

        rule(:domain, :name) do
          unless values[:domain] || values[:name]
            key.failure("must provide either company domain or company name")
          end
        end
      end

      contract_object LookupQueryContract

      schema schema.strict

      attribute? :domain, Types::String
      attribute? :name, Types::String
      attribute? :location, Types::String
      attribute? :enrich, Types::Bool.default(false)

      def self.new(input)
        validation = self.contract_object.new.call(input)
        raise ArgumentError, validation.errors.to_h.inspect unless validation.success?
        super(input)
      end

      def to_request_params
        params = {
          company_domain: domain,
          company_name: name,
          company_location: location,
          enrich_profile: enrich,
        }

        params.each_pair do |key, value|
          params.delete(key) unless value
        end
      end
    end
  end
end
