require_relative "../email_search/travel_advice"
require_relative "../email_verifier"

class EmailVerifier::TravelAdvice < EmailVerifier
  def email_search_queries
    EmailSearch::TravelAdvice.queries
  end
end
