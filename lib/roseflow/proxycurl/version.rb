# frozen_string_literal: true

module Roseflow
  module Proxycurl
    def self.gem_version
      Gem::Version.new(VERSION::STRING)
    end

    module VERSION
      MAJOR = 0
      MINOR = 5
      PATCH = 4
      PRE = nil

      STRING = [MAJOR, MINOR, PATCH, PRE].compact.join(".")
    end
  end
end
