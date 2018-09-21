require_relative "email_search/medical_safety"
require_relative "./alert_email_verifier"

class DrugAlertEmailVerifier < AlertEmailVerifier
  def latest_alert_contents
    EmailSearch::MedicalSafety.queries
  end

  def emails_that_should_have_received_alert
    ENV.fetch('EMAILS_THAT_SHOULD_RECEIVE_DRUG_ALERTS').split(',')
  end
end
