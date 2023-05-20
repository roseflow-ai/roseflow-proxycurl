# frozen_string_literal: true

require "dry-struct"
require "dry-validation"
require "dry-transformer"
require "roseflow/types"

module Roseflow
  module LinkedIn
    class Job
      class Object < Dry::Struct
        class Company < Dry::Struct
          transform_keys(&:to_sym)

          attribute :name, Types::String
          attribute :url, Types::String
        end

        class Location < Dry::Struct
          transform_keys(&:to_sym)

          attribute :country, Types::String
          attribute :city, Types::String
          attribute :region, Types::String.optional
        end

        class JobMapper < Dry::Transformer::Pipe
          import Dry::Transformer::HashTransformations

          define! do
            deep_symbolize_keys
            rename_keys linkedin_internal_id: :id, industry: :industries, job_description: :description
          end
        end

        defines :contract_object

        class JobContract < Dry::Validation::Contract
          params do
            required(:id).filled(:string)
            required(:title).filled(:string)
            required(:description).filled(:string)
            required(:location)
            required(:company)
            required(:seniority_level).filled(:string)
            required(:employment_type).filled(:string)
            required(:industries).filled(:array)
          end

          def call(input)
            transformed = JobMapper.new.call(input)
            super(transformed)
          end
        end

        contract_object JobContract

        schema schema.strict

        attribute :id, Types::String
        attribute :title, Types::String
        attribute :description, Types::String
        attribute :location, Location
        attribute :company, Company
        attribute :seniority_level, Types::String
        attribute :employment_type, Types::String
        attribute :industries, Types::Array

        def self.new(input)
          validation = self.contract_object.new.call(input)
          raise ArgumentError, validation.errors.to_h.inspect unless validation.success?
          super(validation.to_h)
        end
      end
    end
  end
end
