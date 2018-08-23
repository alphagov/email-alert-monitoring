require "open-uri"
require "json"
require "time"
require "tzinfo"

class TravelAdviceAlerts
  HEALTHCHECK_URL = "https://travel-advice-publisher.publishing.service.gov.uk/healthcheck/recently-published-editions".freeze
  EMAIL_DATE_FORMAT = "%l:%M%P, %-d %B %Y".freeze # make sure this matches email-alert-api

  def latest_travel_advice_alerts
    # Extract the countries updated from two days to one hour ago.
    # Unlike with drug alerts, we expect multiple updates from the same set of
    # 225 countries, so search on update time + country rather than the linked url.
    open(HEALTHCHECK_URL) do |raw_json|
      JSON.parse(raw_json.read)["editions"]
        .map { |json_entry| TravelAdviceEntry.new(json_entry) }
        .map(&:search_value)
    end
  end

  class TravelAdviceEntry
    attr_reader :entry

    def initialize(entry)
      @entry = entry
    end

    def timezone
      @timezone ||= TZInfo::Timezone.get("Europe/London")
    end

    def updated_at
      @updated_at ||= timezone.utc_to_local(Time.parse(entry["published_at"]))
    end

    def alert_time
      updated_at.strftime(EMAIL_DATE_FORMAT)
    end

    def subject
      entry["title"]
    end

    def search_value
      %("#{alert_time}" subject:"#{subject}")
    end
  end
end
