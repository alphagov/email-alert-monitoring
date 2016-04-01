require 'open-uri'
require 'json'
require 'time'

class TravelAdviceAlerts
  FEED_URL = "https://www.gov.uk/api/foreign-travel-advice.json"

  def latest_travel_advice_alerts
    # Extract the countries updated from two days to one hour ago.
    # Unlike with drug alerts, we expect multiple updates from the same set of
    # 225 countries, so search on update time + country rather than the linked url.
    open(FEED_URL) do |raw_json|
      JSON.load(raw_json)["details"]["countries"]
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
      @updated_at ||= Time.parse(entry["updated_at"])
    end

    def alert_time
      updated_at.utc.strftime("%d-%m-%Y %H:%M %p GMT")
    end

    def updated_recently?
      Time.now - 172800 <= updated_at && updated_at <= Time.now - 3600
    end

    def country
      entry["name"]
    end

    def search_value
      %Q("#{alert_time}" subject:#{country})
    end
  end
end
