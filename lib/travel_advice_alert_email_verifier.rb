require_relative './travel_advice_alerts'
require_relative './alert_email_verifier'

class TravelAdviceAlertEmailVerifier < AlertEmailVerifier
  def latest_alert_contents
    TravelAdviceAlerts.new.latest_travel_advice_alerts
  end

  def emails_that_should_have_received_alert
    ENV.fetch('EMAILS_THAT_SHOULD_RECEIVE_TRAVEL_ADVICE_ALERTS').split(',')
  end
end
