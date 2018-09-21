require_relative "../email_search/medical_safety"
require_relative "../email_verifier"

class EmailVerifier::MedicalSafety < EmailVerifier
  def email_search_queries
    EmailSearch::MedicalSafety.queries
  end

  def emails_that_should_have_received_alert
    ENV.fetch("EMAILS_THAT_SHOULD_RECEIVE_DRUG_ALERTS").split(",")
  end
end
