require 'open-uri'
require 'json'
require 'time'
require 'active_support/all'

class TravelAdviceAlerts
  FEED_URL = "https://www.gov.uk/api/content/foreign-travel-advice"

  def latest_travel_advice_alerts
    # Extract the countries updated from two days to one hour ago.
    # Unlike with drug alerts, we expect multiple updates from the same set of
    # 225 countries, so search on update time + country rather than the linked url.
    open(FEED_URL) do |raw_json|
      JSON.load(raw_json)["links"]["children"]
        .map { |json_entry| TravelAdviceEntry.new(json_entry) }
        .select(&:updated_recently?)
        .map(&:search_value)
    end
  end

  class TravelAdviceEntry
    attr_reader :entry

    def initialize(entry)
      @entry = entry
    end

    def updated_at
      @updated_at ||= Time.parse(entry["public_updated_at"])
    end

    def alert_time
      updated_at.utc.strftime("%d-%m-%Y %H:%M %p GMT")
    end

    def updated_recently?
      Time.now - 172800 <= updated_at && updated_at <= Time.now - 900
    end

    def country
      I18n.transliterate(entry['country']['name'])
    end

    def search_value
      %Q("#{alert_time}" "#{country}")
    end
  end
end
