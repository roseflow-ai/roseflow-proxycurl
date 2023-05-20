# frozen_string_literal: true

require "dry-validation"
require "roseflow/proxycurl/object"
require "roseflow/linkedin/person"
require "roseflow/types"

module Roseflow
  module LinkedIn
    class Person
      class LookupQuery < Proxycurl::ProxycurlObject
        class LookupQueryContract < Dry::Validation::Contract
          params do
            required(:domain).filled(:string)
            required(:first_name).filled(:string)
            optional(:last_name).filled(:string)
            optional(:title).filled(:string)
            optional(:location).filled(:string)
            optional(:enrich).filled(:bool)
          end
        end

        contract_object LookupQueryContract

        schema schema.strict

        attribute :domain, Types::String
        attribute :first_name, Types::String
        attribute? :last_name, Types::String
        attribute? :title, Types::String
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
            first_name: first_name,
            last_name: last_name,
            title: title,
            location: location,
            enrich_profile: enrich == true ? "enrich" : "skip",
          }

          params.each_pair do |key, value|
            params.delete(key) unless value
          end
        end
      end
    end
  end
end
