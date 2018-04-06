require "pry-byebug"
require_relative "./lib/task_runner"
require "plek"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

def google_auth_client(additional_parameters = nil)
  require "google/api_client/client_secrets"

  unless File.exist?("client_secrets.json")
    raise "`client_secrets.json` needs to be downloaded from the Google "\
      "Developers Console and be present in the root directory of this repo."
  end

  client_secrets = Google::APIClient::ClientSecrets.load("client_secrets.json")
  auth_client = client_secrets.to_authorization
  auth_client.update!(
    scope: "https://www.googleapis.com/auth/gmail.readonly",
    redirect_uri: "http://localhost/oauth",
    additional_parameters: additional_parameters
  )
  auth_client
end

task default: %i[spec lint]

task :lint do
  sh "bundle exec govuk-lint-ruby --format clang lib spec Gemfile"
end

# OAuth step 1: get the URL to visit for authorisation
task :get_oauth_url do
  auth_client = google_auth_client(
    {
      "access_type" => "offline"
    }
  )
  puts auth_client.authorization_uri
end

# OAuth step 2: extract the code from the callback URL and use
# to get the OAuth token
task :get_oauth_token, [:auth_code] do |_t, args|
  auth_client = google_auth_client
  auth_client.code = args[:auth_code]
  auth_client.fetch_access_token!
  auth_client.client_secret = nil
  puts auth_client.to_json
end

task :run do
  require_relative "./lib/drug_alert_email_verifier"

  verifier = DrugAlertEmailVerifier.new
  TaskRunner.new.verify_with_retries(verifier: verifier) do
    if verifier.have_all_alerts_been_emailed?
      puts "All email alerts have been sent. Everything is okay!"

      verifier.acknowledged_alerts.each do |email, url|
        puts "#{email} has not received an email with #{url} but has been acknowledged"
      end
    else
      verifier.missing_alerts.each do |email, url|
        puts "#{email} has not received an email with #{url}"
      end

      exit(2)
    end
  end
end

task :run_travel_alerts do
  require_relative "./lib/travel_advice_alert_email_verifier"

  verifier = TravelAdviceAlertEmailVerifier.new
  TaskRunner.new.verify_with_retries(verifier: verifier) do
    if verifier.have_all_alerts_been_emailed?
      puts "All travel advice email alerts have been sent. Everything is okay!"
    else
      verifier.missing_alerts.each do |email, result|
        /subject:(.*)/.match(result) do |subject|
          puts "#{email} has not received a travel advice alert email with a subject of #{subject[1]}"
        end
      end

      exit(2)
    end
  end
end
