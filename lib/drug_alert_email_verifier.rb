require_relative './drug_alerts'
require_relative './alert_email_verifier'

class DrugAlertEmailVerifier < AlertEmailVerifier
  def latest_alert_contents
    DrugAlerts.new.latest_drug_alert_urls
  end

  def emails_that_should_have_received_alert
    ENV.fetch('EMAILS_THAT_SHOULD_RECEIVE_DRUG_ALERTS').split(',')
  end
end
