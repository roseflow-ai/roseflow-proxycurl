# frozen_string_literal: true

require "roseflow/linkedin/person/lookup_query"
require "roseflow/linkedin/person/profile_query"
require "roseflow/linkedin/person/role_query"

module Roseflow
  module LinkedIn
    class Person
      def initialize(connection)
        @connection = connection
      end

      def find(url, **options)
        query = ProfileQuery.new(url: url, **options)
        response = @connection.get("v2/linkedin", query.to_h)
        return Person::Object.new(JSON.parse(response.body).merge(profile_url: url)) if person_found?(response)
        return nil if person_not_found?(response)
      end

      def lookup(query)
        query = LookupQuery.new(query)
        response = @connection.get("linkedin/profile/resolve", query.to_request_params)
        return JSON.parse(response.body).dig("url") if person_found?(response)
        return nil if person_not_found?(response)
      end

      def role(query)
        query = RoleQuery.new(query)
        response = @connection.get("find/company/role/", query.to_request_params)
        if person_found?(response)
          url = JSON.parse(response.body).dig("linkedin_profile_url")
          return find(url)
        end

        return nil if person_not_found?(response)
      end

      private

      def person_found?(response)
        response.success? && response.status == 200
      end

      def person_not_found?(response)
        response.success? && response.status == 404
      end
    end
  end
end
