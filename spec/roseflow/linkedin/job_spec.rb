# frozen_string_literal: true

require "spec_helper"

require "roseflow/linkedin/job"
require "roseflow/linkedin/job/object"
require "roseflow/proxycurl/config"
require "faraday"

VCR.configure do |config|
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<API_KEY>") { Roseflow::Proxycurl::Config.new.api_key }
end

def proxycurl_connection(config = Roseflow::Proxycurl::Config.new)
  connection = Faraday.new(
    url: Roseflow::Proxycurl::Config::DEFAULT_BASE_URL,
  ) do |faraday|
    faraday.request :authorization, :Bearer, -> { config.api_key }
    faraday.request :url_encoded
    faraday.adapter Faraday.default_adapter
  end
end

module Roseflow
  module LinkedIn
    RSpec.describe Job do
      describe "#find" do
        let(:url) { "https://www.linkedin.com/jobs/view/3599750093" }
        let(:query) { described_class.new(proxycurl_connection).find(url) }

        it "returns a job object" do
          VCR.use_cassette("linkedin/job/find", record: :new_episodes) do
            expect(query).to be_a(described_class::Object)
          end
        end
      end

      describe "#search" do
        let(:params) { { keyword: "ruby" } }
        let(:query) { described_class.new(proxycurl_connection).search(params) }

        it "returns an array of job objects" do
          VCR.use_cassette("linkedin/job/search", record: :new_episodes) do
            expect(query).to be_a(Array)
            expect(query).to all(be_a(JobListEntry))
          end
        end
      end
    end
  end
end
