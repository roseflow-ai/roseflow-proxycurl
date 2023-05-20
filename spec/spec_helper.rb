# frozen_string_literal: true

require "anyway_config"
require "roseflow/proxycurl"
require "webmock/rspec"
require "vcr"

Anyway::Settings.use_local_files = true

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = "spec/fixtures/vcr"
  config.ignore_localhost = true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
