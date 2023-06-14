# frozen_string_literal: true

require "roseflow/linkedin/person/object"
require "roseflow/linkedin/person/lookup_query"
require "roseflow/linkedin/person/profile_query"
require "roseflow/linkedin/person/role_query"

module Roseflow
  module LinkedIn
    class Person
      def initialize(client = Roseflow::Proxycurl::Client.new)
        @client = client
      end

      def find(url, **options)
        query = ProfileQuery.new(url: url, **options)
        response = @client.find_person(query)
        return Person::Object.new(JSON.parse(response.body).merge(profile_url: url)) if person_found?(response)
        return nil if person_not_found?(response)
      end

      def lookup(query)
        query = LookupQuery.new(query)
        response = @client.lookup_person(query)
        return JSON.parse(response.body).dig("url") if person_found?(response)
        return nil if person_not_found?(response)
      end

      def role(query)
        query = RoleQuery.new(query)
        response = @client.find_person_in_role(query)
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
