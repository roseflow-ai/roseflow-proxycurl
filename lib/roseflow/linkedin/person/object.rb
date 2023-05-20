# frozen_string_literal: true

require "dry-transformer"

require "roseflow/linkedin/person/experience"

module Roseflow
  module LinkedIn
    class Person
      class Object < Dry::Struct
        defines :contract_object

        class PersonMapper < Dry::Transformer::Pipe
          import Dry::Transformer::HashTransformations

          define! do
            deep_symbolize_keys
            rename_keys public_identifier: :id, profile_pic_url: :profile_picture_url, follower_count: :followers
          end
        end

        class PersonContract < Dry::Validation::Contract
          params do
            required(:id).filled(:string)
            required(:first_name).filled(:string)
            required(:last_name).filled(:string)
            required(:full_name).filled(:string)
            required(:profile_url).filled(:string)
            required(:profile_picture_url).filled(:string)
            required(:headline).filled(:string)
            optional(:followers)
            optional(:connections)
            optional(:occupation)
            optional(:experiences).filled(:array)
          end

          def call(input)
            transformed = PersonMapper.new.call(input)
            super(transformed)
          end
        end

        attribute :id, Types::String
        attribute :first_name, Types::String
        attribute :last_name, Types::String
        attribute :full_name, Types::String
        attribute :profile_url, Types::String
        attribute :profile_picture_url, Types::String
        attribute :headline, Types::String
        attribute :followers, Types::Integer.optional
        attribute :connections, Types::Integer.optional
        attribute :occupation, Types::String
        attribute :experiences, Types::Array.of(Experience).optional

        contract_object PersonContract

        schema schema.strict

        def self.new(input)
          experiences = input.delete("experiences")
          input[:experiences] = experiences.map { |experience| Experience.new(experience) } if experiences
          validation = self.contract_object.new.call(input)
          raise ArgumentError, validation.errors.to_h.inspect unless validation.success?
          super(validation.to_h)
        end
      end
    end
  end
end
