require_relative "../email_search/travel_advice"
require_relative "../email_verifier"

class EmailVerifier::TravelAdvice < EmailVerifier
  def latest_alert_contents
    EmailSearch::TravelAdvice.queries
  end

  def emails_that_should_have_received_alert
    ENV.fetch("EMAILS_THAT_SHOULD_RECEIVE_TRAVEL_ADVICE_ALERTS").split(",")
  end
end
