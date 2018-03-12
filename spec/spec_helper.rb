require 'webmock/rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random
  Kernel.srand config.seed
end

def set_credentials
  ENV['GOOGLE_OAUTH_CREDENTIALS'] = '{"client_id":"my-google-client-id","access_token":"my-access-token","refresh_token":"my-refresh-token","scope":["https://www.googleapis.com/auth/gmail.readonly"],"expiration_time_millis":1454336608000}'
  ENV['GOOGLE_CLIENT_ID'] = 'my-google-client-id'
  ENV['GOOGLE_CLIENT_SECRET'] = 'my-google-client-secret'
  ENV['EMAILS_THAT_SHOULD_RECEIVE_DRUG_ALERTS'] = 'a@example.org,b@example.org'
  ENV['EMAILS_THAT_SHOULD_RECEIVE_TRAVEL_ADVICE_ALERTS'] = 'c@example.org'

  # the response there doesn't matter, as long as it's JSON.
  stub_request(:post, "https://www.googleapis.com/oauth2/v4/token").
    to_return(body: "{}", headers: { "Content-Type" => "application/json" })
end
