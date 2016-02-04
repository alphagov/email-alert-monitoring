task :run do
  require_relative './lib/drug_alert_email_verifier'

  verifier = DrugAlertEmailVerifier.new

  if verifier.have_all_alerts_been_emailed?
    puts "All email alerts have been sent. Everything is okay!"
  else
    verifier.missing_alerts.each do |email, url|
      puts "#{email} has not received an email with #{url}"
    end

    exit(1)
  end
end
