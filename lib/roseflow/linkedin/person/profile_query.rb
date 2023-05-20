# frozen_string_literal: true

require "dry-validation"
require "roseflow/proxycurl/object"
require "roseflow/linkedin/person"
require "roseflow/types"

module Roseflow
  module LinkedIn
    class Person
    end

    class Person::ProfileQuery < Proxycurl::ProxycurlObject
      class ProfileQueryContract < Dry::Validation::Contract
        params do
          required(:url).filled(:string)
        end

        rule (:url) do
          unless URI.parse(value).is_a?(URI::HTTP)
            key.failure("must be a valid URL")
          end

          unless value.match?(/linkedin\.com\/in\/\w+/)
            key.failure("must be a valid LinkedIn profile URL")
          end
        end
      end

      contract_object ProfileQueryContract

      schema schema.strict

      attribute :url, Types::String
      attribute :fallback_to_cache, Types::String.default("on-error")
      attribute :use_cache, Types::String.default("if-present")
      attribute :skills, Types::String.default("exclude")
      attribute :inferred_salary, Types::String.default("exclude")
      attribute :personal_email, Types::String.default("exclude")
      attribute :personal_contact_number, Types::String.default("exclude")
      attribute :twitter_profile_id, Types::String.default("exclude")
      attribute :facebook_profile_id, Types::String.default("exclude")
      attribute :github_profile_id, Types::String.default("exclude")
      attribute :extra, Types::String.default("exclude")

      def self.new(input)
        validation = self.contract_object.new.call(input)
        raise ArgumentError, validation.errors.to_h.inspect unless validation.success?
        super(input)
      end
    end
  end
end
