# frozen_string_literal: true

module Types
  DateOrNil = Date | Nil
  StringOrNil = String | Nil
end

module Functions
  extend Dry::Transformer::Registry

  register :to_date, ->(v) { Date.parse("#{v.dig(:year)}-#{v.dig(:month)}-#{v.dig(:day)}") unless v.nil? }
end

module Roseflow
  module LinkedIn
    class Person
      class ExperienceMapper < Dry::Transformer::Pipe
        import Dry::Transformer::HashTransformations

        def custom_t(*args)
          Functions[*args]
        end

        define! do
          deep_symbolize_keys
          rename_keys company_linkedin_profile_url: :company_profile_url, starts_at: :started_on, ends_at: :ended_on

          map_value :started_on, ->(v) { Date.parse("#{v.dig(:year)}-#{v.dig(:month)}-#{v.dig(:day)}") unless v.nil? }
          map_value :ended_on, ->(v) { Date.parse("#{v.dig(:year)}-#{v.dig(:month)}-#{v.dig(:day)}") unless v.nil? }
        end
      end

      class Experience < Dry::Struct
        defines :contract_object

        class ExperienceContract < Dry::Validation::Contract
          params do
            required(:title).filled(:string)
            required(:company).filled(:string)
            optional(:company_profile_url).filled(:string)
            optional(:location)
            optional(:description)
            optional(:started_on)
            optional(:ended_on)
          end

          def call(input)
            transformed = ExperienceMapper.new.call(input)
            super(transformed)
          end
        end

        attribute :title, Types::String
        attribute :company, Types::String
        attribute? :company_profile_url, Types::StringOrNil
        attribute? :location, Types::StringOrNil
        attribute? :description, Types::StringOrNil
        attribute? :started_on, Types::DateOrNil
        attribute? :ended_on, Types::DateOrNil

        contract_object ExperienceContract

        schema schema.strict

        def self.new(input)
          validation = self.contract_object.new.call(input)
          raise ArgumentError, validation.errors.to_h unless validation.success?
          super(validation.to_h)
        end
      end
    end
  end
end
