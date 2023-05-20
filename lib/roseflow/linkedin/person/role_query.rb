# frozen_string_literal: true

require "dry-validation"
require "roseflow/proxycurl/object"
require "roseflow/linkedin/person"
require "roseflow/types"

module Roseflow
  module LinkedIn
    class Person
      class RoleQuery < Proxycurl::ProxycurlObject
        class RoleQueryContract < Dry::Validation::Contract
          params do
            required(:role).filled(:string)
            required(:company_name).filled(:string)
            optional(:enrich).filled(:bool)
          end
        end

        contract_object RoleQueryContract

        schema schema.strict

        attribute :role, Types::String
        attribute :company_name, Types::String
        attribute? :enrich, Types::Bool.default(false)

        def self.new(input)
          validation = self.contract_object.new.call(input)
          raise ArgumentError, validation.errors.to_h.inspect unless validation.success?
          super(input)
        end

        def to_request_params
          params = {
            company_name: company_name,
            role: role,
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
