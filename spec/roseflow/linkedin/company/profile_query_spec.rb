# frozen_string_literal: true

require "spec_helper"
require "roseflow/linkedin/company"
require "roseflow/linkedin/company/profile_query"
require "roseflow/proxycurl/object"

module Roseflow
  module LinkedIn
    RSpec.describe Company::ProfileQuery do
      describe "Validation" do
        let(:url) { "https://www.linkedin.com/company/finitec-oy/" }
        let(:query) { described_class.new(url: url) }

        it "is valid with a valid URL" do
          expect(query).to be_a described_class
        end

        it "raises error with non-URL string" do
          expect { described_class.new(url: "foo") }.to raise_error(ArgumentError)
        end

        it "raises error with non-LinkedIn URL" do
          expect { described_class.new(url: "https://roseflow.ai/") }.to raise_error(ArgumentError)
        end
      end

      describe "Defaults" do
        let(:url) { "https://www.linkedin.com/company/finitec-oy/" }
        let(:query) { described_class.new(url: url) }

        it "has a default value for resolve_numeric_id" do
          expect(query.resolve_numeric_id).to eq(false)
        end

        it "has a default value for categories" do
          expect(query.categories).to eq("exclude")
        end

        it "has a default value for funding_data" do
          expect(query.funding_data).to eq("exclude")
        end

        it "has a default value for extra" do
          expect(query.extra).to eq("exclude")
        end

        it "has a default value for exit_data" do
          expect(query.exit_data).to eq("exclude")
        end

        it "has a default value for acquisitions" do
          expect(query.acquisitions).to eq("exclude")
        end

        it "has a default value for use_cache" do
          expect(query.use_cache).to eq("if-present")
        end
      end
    end
  end
end
