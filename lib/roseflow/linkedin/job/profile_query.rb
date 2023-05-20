# frozen_string_literal: true

require "dry-validation"
require "roseflow/proxycurl/object"
require "roseflow/linkedin/job"
require "roseflow/types"

module Roseflow
  module LinkedIn
    class Job
      class ProfileQuery < Proxycurl::ProxycurlObject
        class ProfileQueryContract < Dry::Validation::Contract
          params do
            required(:url).filled(:string)
          end
        end

        contract_object ProfileQueryContract

        schema schema.strict

        attribute :url, Types::String

        def self.new(input)
          validation = self.contract_object.new.call(input)
          raise ArgumentError, validation.errors.to_h.inspect unless validation.success?
          super(input)
        end
      end
    end
  end
end
