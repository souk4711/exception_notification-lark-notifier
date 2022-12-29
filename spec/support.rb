require "dotenv/load"
require "vcr"
require "webmock"

VCR.configure do |config|
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = "spec/cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data("<LARK_NOTIFIER_WEBHOOK_URL>") do |interaction|
    ENV["LARK_NOTIFIER_WEBHOOK_URL"]
  end
end
