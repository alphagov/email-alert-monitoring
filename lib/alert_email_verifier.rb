require_relative './inbox'

class AlertEmailVerifier
  attr_reader :missing_alerts, :emailed_alerts, :acknowledged_alerts

  ACKNOWLEDGED_EMAIL_CONTENTS = [
    "https://www.gov.uk/drug-device-alerts/field-safety-notices-22-26-august-2016",
    "https://www.gov.uk/drug-device-alerts/accu-chek-insight-insulin-pump-system-risk-of-over-or-under-infusion-of-insulin",
    "https://www.gov.uk/drug-device-alerts/airvo-2-and-myairvo-2-humidifier-risk-of-undetected-auditory-alarm",
  ].freeze

  def initialize
    @emailed_alerts = []
    @acknowledged_alerts = []
    @missing_alerts = []
  end

  def have_all_alerts_been_emailed?
    @missing_alerts.empty?
  end

  def run_report
    latest_alert_contents.all? do |contents|
      emails_that_should_have_received_alert.all? do |email|
        if has_email_address_received_email_with_contents?(email: email, contents: contents)
          @emailed_alerts << [email, contents]
        elsif acknowledged_as_missing?(contents: contents)
          @acknowledged_alerts << [email, contents]
        else
          @missing_alerts << [email, contents]
        end
      end
    end
  end

private

  def has_email_address_received_email_with_contents?(email:, contents:)
    query = "#{contents} to:#{email}"
    count = inbox.message_count_for_query(query)
    count != 0
  end

  def acknowledged_as_missing?(contents:)
    ACKNOWLEDGED_EMAIL_CONTENTS.include?(contents)
  end

  def inbox
    @inbox ||= Inbox.new
  end

  def latest_alert_contents
    []
  end
end
