# frozen_string_literal: true

require "roseflow/linkedin/company/profile_query"
require "roseflow/linkedin/company/lookup_query"

module Roseflow
  module LinkedIn
    class Company
      def initialize(client = Roseflow::Proxycurl::Client.new)
        @client = client
      end

      def find(url, **options)
        query = ProfileQuery.new(url: url, **options)
        response = @client.find_company(query)
        return Company::Object.new(JSON.parse(response.body).merge("profile_url" => url)) if company_found?(response)
        return nil if company_not_found?(response)
      end

      def lookup(query)
        query = LookupQuery.new(query)
        response = @client.lookup_company(query)
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
