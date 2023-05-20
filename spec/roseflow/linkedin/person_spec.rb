# frozen_string_literal: true

require "spec_helper"
require "faraday"
require "roseflow/linkedin/person"
require "roseflow/linkedin/person/object"
require "roseflow/proxycurl/config"

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
    RSpec.describe Person do
      describe "#find" do
        let(:url) { "https://www.linkedin.com/in/ljuti/" }

        it "returns a response with a valid URL" do
          VCR.use_cassette("linkedin/person/find", record: :new_episodes) do
            object = described_class.new(proxycurl_connection).find(url)
            expect(object).to be_a Person::Object
            expect(object.full_name).to eq("Lauri Jutila")
          end
        end

        it "returns nil with an invalid URL" do
          VCR.use_cassette("linkedin/person/find_invalid", record: :new_episodes) do
            object = described_class.new(proxycurl_connection).find("https://www.linkedin.com/in/foo-bar-does-not-exist/")
            expect(object).to be_nil
          end
        end
      end

      describe "#lookup" do
        let(:company_domain) { "cyberdo.fi" }
        let(:first_name) { "Anssi" }

        it "returns a person with valid parameters" do
          VCR.use_cassette("linkedin/person/lookup", record: :new_episodes) do
            expect(described_class.new(proxycurl_connection).lookup(domain: company_domain, first_name: first_name)).to eq "https://fi.linkedin.com/in/anssi-p-k%C3%A4rkk%C3%A4inen"
          end
        end

        it "returns nil when it can't find a person" do
          VCR.use_cassette("linkedin/person/lookup_invalid", record: :new_episodes) do
            expect(described_class.new(proxycurl_connection).lookup(domain: company_domain, first_name: "Nalle", last_name: "Puh")).to be_nil
          end
        end
      end

      describe "#role" do
        let(:company_name) { "Finitec Oy" }
        let(:role) { "Chief Technology Officer" }

        it "returns a person" do
          VCR.use_cassette("linkedin/person/role", record: :new_episodes) do
            expect(described_class.new(proxycurl_connection).role(company_name: company_name, role: role)).to be_a Person::Object
          end
        end
      end
    end
  end
end
