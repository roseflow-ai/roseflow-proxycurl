# frozen_string_literal: true

require "roseflow/linkedin/company/profile_query"
require "roseflow/linkedin/company/lookup_query"

module Roseflow
  module LinkedIn
    class Company
      def initialize(connection)
        @connection = connection
      end

      def find(url, **options)
        query = ProfileQuery.new(url: url, **options)
        response = @connection.get("linkedin/company", query.to_h)
        return Company::Object.new(JSON.parse(response.body).merge("profile_url" => url)) if company_found?(response)
        return nil if company_not_found?(response)
      end

      def lookup(query)
        query = LookupQuery.new(query)
        response = @connection.get("linkedin/company/resolve", query.to_request_params)
        return JSON.parse(response.body).dig("url") if company_found?(response)
        return nil if company_not_found?(response)
      end

      private

      def company_found?(response)
        response.success? && response.status == 200
      end

      def company_not_found?(response)
        response.success? && response.status == 404
      end
    end
  end
end
