# frozen_string_literal: true

module Roseflow
  module LinkedIn
    class JobListEntry < Dry::Struct
      attribute :company, Types::String
      attribute :company_url, Types::String
      attribute :job_title, Types::String
      attribute :job_url, Types::String
      attribute :list_date, Types::String
      attribute :location, Types::String

      def self.from(input)
        entries = input.dig("job")
        return [] unless entries
        entries.map { |entry| new(entry.symbolize_keys) }
      end
    end
  end
end
