# frozen_string_literal: true

require_relative "proxycurl/version"
require "roseflow/proxycurl/client"
require "roseflow/proxycurl/config"
require "roseflow/proxycurl/object"

require "roseflow/linkedin/company"
require "roseflow/linkedin/job"
require "roseflow/linkedin/job_list_entry"
require "roseflow/linkedin/person"

module Roseflow
  module Proxycurl
    class Error < StandardError; end
  end
end
