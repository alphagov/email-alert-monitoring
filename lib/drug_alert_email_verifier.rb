require_relative './inbox'
require_relative './drug_alerts'

class DrugAlertEmailVerifier
  attr_reader :missing_alerts

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
    latest_drug_alert_urls.all? do |url|
      emails_that_should_have_received_alert.all? do |email|
        if has_email_address_received_email_with_contents?(email: email, contents: url)
          @emailed_alerts << [email, url]
        else
          @missing_alerts << [email, url]
        end
      end
    end
  end

  def emails_that_should_have_received_alert
    ENV.fetch('EMAILS_THAT_SHOULD_RECEIVE_DRUG_ALERTS').split(',')
  end

  def has_email_address_received_email_with_contents?(email:, contents:)
    count = inbox.message_count_for_query("#{contents} to:#{email}")
    count != 0
  end

  def inbox
    @inbox ||= Inbox.new
  end

  def latest_drug_alert_urls
    DrugAlerts.new.latest_drug_alert_urls
  end
end
