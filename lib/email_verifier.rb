require_relative "inbox"

class EmailVerifier
  attr_reader :missing_alerts, :emailed_alerts, :acknowledged_alerts

  ACKNOWLEDGED_EMAIL_CONTENTS = [
    %{subject:"Field Safety Notice - 02 to 06 April 2018"},
    %{subject:"Imatinib 400mg Capsules (3 x 10)  PL 36390/0180 : Company-led Drug Alert"},
  ].freeze

  def initialize
    @emailed_alerts = []
    @acknowledged_alerts = []
    @missing_alerts = []
    @inbox = Inbox.new
  end

  def have_all_alerts_been_emailed?
    @missing_alerts.empty?
  end

  def run_report
    email_search_queries.all? do |email_search_query|
      emails_that_should_have_received_alert.all? do |email|
        if has_email_address_received_email_with_contents?(email: email, contents: email_search_query)
          @emailed_alerts << [email, email_search_query]
        elsif acknowledged_as_missing?(contents: email_search_query)
          @acknowledged_alerts << [email, email_search_query]
        else
          @missing_alerts << [email, email_search_query]
        end
      end
    end
  end

private

  attr_reader :inbox

  def has_email_address_received_email_with_contents?(email:, contents:)
    inbox.message_count_for_query("#{contents} to:#{email}") != 0
  end

  def acknowledged_as_missing?(contents:)
    ACKNOWLEDGED_EMAIL_CONTENTS.include?(contents)
  end
end
