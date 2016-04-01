require_relative './inbox'

class AlertEmailVerifier
  attr_reader :missing_alerts, :emailed_alerts

  def initialize
    @emailed_alerts = []
    @missing_alerts = []
    run_report
  end

  def have_all_alerts_been_emailed?
    @missing_alerts.empty?
  end

private
  def run_report
    latest_alert_contents.all? do |contents|
      emails_that_should_have_received_alert.all? do |email|
        if has_email_address_received_email_with_contents?(email: email, contents: contents)
          @emailed_alerts << [email, contents]
        else
          @missing_alerts << [email, contents]
        end
      end
    end
  end

  def has_email_address_received_email_with_contents?(email:, contents:)
    count = inbox.message_count_for_query("#{contents} to:#{email}")
    count != 0
  end

  def inbox
    @inbox ||= Inbox.new
  end

  def latest_alert_contents
    []
  end
end
