# frozen_string_literal: true

require "dry-transformer"

module Roseflow
  module LinkedIn
    module CompanyTransformations
      extend Dry::Transformer::Registry

      import Dry::Transformer::ArrayTransformations
      import Dry::Transformer::HashTransformations

      rename_keys = t(:map_keys, linkedin_internal_id: :id, universal_name_id: :shorthand)

      # Transformation = t(:compose, t(:symbolize_keys), rename_keys)
    end

    class CompanyMapper < Dry::Transformer::Pipe
      import Dry::Transformer::HashTransformations

      define! do
        symbolize_keys
        rename_keys linkedin_internal_id: :id, universal_name_id: :shorthand, website: :url
      end
    end

    class Company
      class Object < Dry::Struct
        defines :contract_object

        class CompanyContract < Dry::Validation::Contract
          params do
            required(:id).filled(:string)
            required(:name).filled(:string)
            required(:profile_url).filled(:string)
            required(:url).filled(:string)
            required(:shorthand).filled(:string)
            required(:tagline).filled(:string)
            required(:description).filled(:string)
            required(:industry).filled(:string)
            required(:company_type).filled(:string)
            required(:locations).array(:hash) do
              required(:country).filled(:string)
              required(:city).filled(:string)
              required(:is_hq).filled(:bool)
            end
          end

          def call(input)
            transformed = CompanyMapper.new.call(input)
            super(transformed)
          end
        end

        attribute :id, Types::String
        attribute :name, Types::String
        attribute :profile_url, Types::String
        attribute :url, Types::String
        attribute :shorthand, Types::String
        attribute :tagline, Types::String
        attribute :description, Types::String
        attribute :industry, Types::String
        attribute :company_type, Types::String
        attribute :locations, Types::Array do
          attribute :country, Types::String
          attribute :city, Types::String
          attribute :is_hq, Types::Bool
        end

        contract_object CompanyContract

        schema schema.strict

        def self.new(input)
          validation = self.contract_object.new.call(input)
          raise ArgumentError, validation.errors.to_h.inspect unless validation.success?
          super(validation.to_h)
        end
      end
    end
  end
end
