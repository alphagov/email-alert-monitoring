require "open-uri"
require "json"
require "time"
require "tzinfo"

module EmailSearch
  class TravelAdvice
    HEALTHCHECK_URL = "https://travel-advice-publisher.publishing.service.gov.uk/healthcheck/recently-published-editions".freeze
    EMAIL_DATE_FORMAT = "%l:%M%P, %-d %B %Y".freeze # make sure this matches email-alert-api

    def self.queries
      new.queries
    end

    def queries
      # Extract the countries updated from two days to one hour ago.
      # Unlike with drug alerts, we expect multiple updates from the same set of
      # 225 countries, so search on update time + country rather than the linked url.
      URI.parse(HEALTHCHECK_URL).open do |raw_json|
        JSON.parse(raw_json.read)["editions"]
          .map { |entry| entry_to_query(entry) }
      end
    end

  private

    def timezone
      @timezone ||= TZInfo::Timezone.get("Europe/London")
    end

    def entry_to_query(entry)
      subject = entry["title"]
      date = timezone.utc_to_local(Time.parse(entry["published_at"])).strftime(EMAIL_DATE_FORMAT)

      %("#{date}" subject:"#{subject}")
    end
  end
end
