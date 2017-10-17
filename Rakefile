require "pry-byebug"
require_relative "./lib/task_runner"
require "plek"
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :run do
  require_relative './lib/drug_alert_email_verifier'

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
  require_relative './lib/travel_advice_alert_email_verifier'

  verifier = TravelAdviceAlertEmailVerifier.new
  TaskRunner.new.verify_with_retries(verifier: verifier) do
    if verifier.have_all_alerts_been_emailed?
      puts "All travel advice email alerts have been sent. Everything is okay!"
    else
      verifier.missing_alerts.each do |email, result|
        /subject:(.*)/.match(result) do |subject|
          puts "#{email} has not receieved a travel advice alert email with a subject of #{[1]}"
        end
      end

      exit(2)
    end
  end
end
