# frozen_string_literal: true

require "roseflow/linkedin/job/profile_query"
require "roseflow/linkedin/job/search_query"
require "roseflow/linkedin/job_list_entry"

module Roseflow
  module LinkedIn
    class Job
      def initialize(connection)
        @connection = connection
      end

      def find(url, **options)
        query = ProfileQuery.new(url: url, **options)
        response = @connection.get("linkedin/job", query.to_h)
        return Job::Object.new(JSON.parse(response.body).merge(url: url)) if job_found?(response)
        return nil if job_not_found?(response)
      end

      def search(query)
        query = SearchQuery.new(query)
        response = @connection.get("v2/linkedin/company/job", query.to_request_params)
        return JobListEntry.from(JSON.parse(response.body)) if job_found?(response)
      end

      private

      def job_found?(response)
        response.success? && response.status == 200
      end

      def job_not_found?(response)
        response.success? && response.status == 404
      end
    end # Job
  end # LinkedIn
end # Roseflow
