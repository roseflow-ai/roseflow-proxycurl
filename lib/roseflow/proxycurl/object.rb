# frozen_string_literal: true

require "dry-struct"

module Roseflow
  module Proxycurl
    class ProxycurlObject < Dry::Struct
      defines :contract_object
    end
  end
end
