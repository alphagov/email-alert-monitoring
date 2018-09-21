require_relative "inbox"

class EmailVerifier
  attr_reader :missing_alerts, :emailed_alerts, :acknowledged_alerts

  ACKNOWLEDGED_EMAIL_CONTENTS = [
    %{subject:"Field Safety Notice - 02 to 06 April 2018"},
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
    count = inbox.message_count_for_query("#{contents} to:#{email}")
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
