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
      email_addresses_to_check.all? do |to_email, from_email|
        if has_email_address_received_email_with_contents?(to: to_email, from: from_email, contents: email_search_query)
          @emailed_alerts << [to_email, from_email, email_search_query]
        elsif acknowledged_as_missing?(contents: email_search_query)
          @acknowledged_alerts << [to_email, from_email, email_search_query]
        else
          @missing_alerts << [to_email, from_email, email_search_query]
        end
      end
    end
  end

private

  attr_reader :inbox

  def has_email_address_received_email_with_contents?(to:, from:, contents:)
    query = "#{contents} from:#{from} to:#{to}"
    result = inbox.message_count_for_query(query)
    result != 0
  end

  def acknowledged_as_missing?(contents:)
    ACKNOWLEDGED_EMAIL_CONTENTS.include?(contents)
  end

  def email_addresses_to_check
    ENV.fetch("EMAIL_ADDRESSES_TO_CHECK").split(":").map do |token|
      token.split(",")
    end
  end
end
