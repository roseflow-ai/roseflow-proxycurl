# frozen_string_literal: true

require "roseflow/proxycurl/config"

module Roseflow
  module Proxycurl
    class Client
      attr_reader :config

      def initialize(config = Config.new)
        @config = config
      end

      def find_person(query)
        connection.get("v2/linkedin", query.to_h)
      end

      def find_person_in_role(query)
        connection.get("find/company/role/", query.to_request_params)
      end

      def lookup_person(query)
        connection.get("linkedin/profile/resolve", query.to_request_params)
      end

      def find_company(query)
        connection.get("linkedin/company", query.to_h)
      end

      def lookup_company(query)
        connection.get("linkedin/company/resolve", query.to_request_params)
      end

      private

      def connection
        @connection ||= Faraday.new(
          url: proxycurl_base_url,
        ) do |faraday|
          faraday.request :authorization, :Bearer, -> { config.api_key }
          faraday.request :url_encoded
          faraday.adapter Faraday.default_adapter
        end
      end

      def proxycurl_base_url
        @config.base_url || Config::DEFAULT_BASE_URL
      end
    end
  end
end
