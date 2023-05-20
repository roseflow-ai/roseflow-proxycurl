# frozen_string_literal: true

require "anyway_config"

module Roseflow
  module Proxycurl
    class Config < Anyway::Config
      DEFAULT_BASE_URL = "https://nubela.co/proxycurl/api/"

      config_name :proxycurl

      attr_config :api_key, :base_url

      required :api_key
    end
  end
end
