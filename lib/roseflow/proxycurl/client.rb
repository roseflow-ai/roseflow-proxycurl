# frozen_string_literal: true

module Roseflow
  module Proxycurl
    class Client
      def initialize(config = Config.new)
        @config = config
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
