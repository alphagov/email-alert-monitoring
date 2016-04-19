require "pry-byebug"
require "airbrake"
require_relative "./lib/task_runner"
require "plek"

if ENV['ERRBIT_API_KEY']
  errbit_uri = Plek.find_uri('errbit')
  Airbrake.configure do |config|
    config.api_key = ENV['ERRBIT_API_KEY']
    config.host = errbit_uri.host
    config.secure = errbit_uri.scheme == 'https'
    config.environment_name = ENV['ERRBIT_ENVIRONMENT_NAME']
  end
end

task :run do
  require_relative './lib/drug_alert_email_verifier'

  verifier = DrugAlertEmailVerifier.new
  TaskRunner.new.verify_with_retries(verifier: verifier) do
    if verifier.have_all_alerts_been_emailed?
      puts "All email alerts have been sent. Everything is okay!"
    else
      verifier.missing_alerts.each do |email, url|
        puts "#{email} has not received an email with #{url}"
      end

      exit(2)
    end
  end
end

task :run_travel_alerts do
  require_relative './lib/travel_advice_alert_email_verifier'

  verifier = TravelAdviceAlertEmailVerifier.new
  TaskRunner.new.verify_with_retries(verifier: verifier) do
    if verifier.have_all_alerts_been_emailed?
      puts "All travel advice email alerts have been sent. Everything is okay!"
    else
      verifier.missing_alerts.each do |email, result|
        /subject:(.*)/.match(result) do |country|
          puts "#{email} has not received a travel advice email for #{country[1]}"
        end
      end

      exit(2)
    end
  end
end

