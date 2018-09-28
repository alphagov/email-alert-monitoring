require_relative "../email_search/medical_safety"
require_relative "../email_verifier"

class EmailVerifier::MedicalSafety < EmailVerifier
  def email_search_queries
    EmailSearch::MedicalSafety.queries
  end
end
