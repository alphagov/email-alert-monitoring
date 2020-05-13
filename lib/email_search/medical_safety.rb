require "rss"
require "open-uri"

module EmailSearch
  class MedicalSafety
    FEED_URL = "https://www.gov.uk/drug-device-alerts.atom".freeze
    NUMBER_OF_ITEMS = 5

    # Fetch the latest drug alerts from the RSS feed. Because we expect a little
    # lag between publication and emailing, only return the publications older
    # than an hour. This prevents false negatives.
    def self.queries
      URI.parse(FEED_URL).open do |raw_rss|
        RSS::Parser
          .parse(raw_rss)
          .items.first(NUMBER_OF_ITEMS)
          .select { |entry| entry.updated.content < Time.now - 3600 }
          .map { |entry| %(subject:"#{entry.title.content}") }
      end
    end
  end
end
