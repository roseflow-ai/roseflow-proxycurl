# frozen_string_literal: true

require "spec_helper"
require "faraday"
require "roseflow/linkedin/company"
require "roseflow/linkedin/company/object"
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
    RSpec.describe Company do
      describe "#find" do
        let(:url) { "https://www.linkedin.com/company/finitec-oy/" }

        it "returns a response with a valid URL" do
          VCR.use_cassette("linkedin/company/find", record: :new_episodes) do
            object = described_class.new(proxycurl_connection).find(url)
            expect(object).to be_a Company::Object
            expect(object.name).to eq("Finitec Oy")
          end
        end

        it "returns nil with a non-existing company URL" do
          VCR.use_cassette("linkedin/company/find-non-existing", record: :new_episodes) do
            object = described_class.new(proxycurl_connection).find("https://www.linkedin.com/company/foobar/")
            expect(object).to be_nil
          end
        end
      end

      describe "#lookup" do
        let(:company_domain) { "finitec.fi" }
        let(:company_name) { "Finitec Oy" }

        it "returns a response with a valid domain" do
          VCR.use_cassette("linkedin/company/lookup/domain", record: :new_episodes) do
            object = described_class.new(proxycurl_connection).lookup(domain: company_domain)
            expect(object).to eq "https://www.linkedin.com/company/finitec-oy"
          end
        end

        it "returns a response with a valid name" do
          VCR.use_cassette("linkedin/company/lookup/name", record: :new_episodes) do
            object = described_class.new(proxycurl_connection).lookup(name: "Finitec Oy")
            expect(object).to eq "https://www.linkedin.com/company/finitec-oy"
          end
        end

        it "returns nil with a non-existing domain" do
          VCR.use_cassette("linkedin/company/lookup/non-existing-domain", record: :new_episodes) do
            expect(described_class.new(proxycurl_connection).lookup(domain: "nonexistingdomain.fi")).to be_nil
          end
        end

        it "returns nil with a non-existing name" do
          VCR.use_cassette("linkedin/company/lookup/non-existing-name", record: :new_episodes) do
            expect(described_class.new(proxycurl_connection).lookup(name: "Tätä firmaa ei ole enää olemassa")).to be_nil
          end
        end
      end
    end
  end
end
