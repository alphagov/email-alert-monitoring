require "spec_helper"
require "timecop"
require_relative "../../lib/email_verifier/travel_advice"

RSpec.describe EmailVerifier::TravelAdvice do
  let(:verifier) { described_class.new.tap(&:run_report) }

  before do
    set_credentials
    Timecop.freeze(Time.gm(2016, 3, 31, 17, 30))
  end

  after do
    Timecop.return
  end

  context "when there are travel advice alerts updated between two days and one hour ago" do
    before do
      stub_request(:get, EmailSearch::TravelAdvice::HEALTHCHECK_URL)
        .to_return(body: File.read(File.dirname(__FILE__) + "/example_travel_advice_publisher_healthcheck.json"))
    end

    context "when all emails are sent" do
      before do
        stub_request(:get, "https://gmail.googleapis.com/gmail/v1/users/me/messages")
          .with(query: hash_including(:q))
          .to_return(body: { resultSizeEstimate: 1 }.to_json, headers: { "Content-Type" => "application/json" })
      end

      it "reports that all items have been sent via email" do
        expect(verifier.have_all_alerts_been_emailed?).to be true
        expect(verifier.emailed_alerts.length).to eql(6)
      end

      context "when the subject of travel advice doesn't match the country name" do
        before do
          json = File.read(File.dirname(__FILE__) + "/example_travel_advice_publisher_healthcheck.json")
          json = json.gsub("São Tomé and Principe travel advice", "Sao Tome & Principe travel advice")
          stub_request(:get, EmailSearch::TravelAdvice::HEALTHCHECK_URL).to_return(body: json)
        end

        it "requests based on the title attribute rather than the country name" do
          expect(verifier.have_all_alerts_been_emailed?).to eql(true)
          expect(
            a_request(:get, "https://gmail.googleapis.com/gmail/v1/users/me/messages")
            .with(
              query: {
                q: "\" 3:57pm, 31 March 2016\" subject:\"Sao Tome & Principe travel advice\" from:#{EmailVerifier::FROM_EMAIL} to:#{EmailVerifier::TO_EMAIL}",
                maxResults: "10000",
              },
            ),
          ).to have_been_made
        end
      end

      context "when a travel advice item is updated but email has not been sent" do
        before do
          json = File.read(File.dirname(__FILE__) + "/example_travel_advice_publisher_healthcheck.json")
          json = json.gsub("2016-03-30T12:24:46.000Z", "2016-03-31T15:24:46.000Z")
          stub_request(:get, EmailSearch::TravelAdvice::HEALTHCHECK_URL).to_return(body: json)

          stub_request(:get, "https://gmail.googleapis.com/gmail/v1/users/me/messages")
            .with(
              query: {
                q: "\" 4:24pm, 31 March 2016\" subject:\"Albania travel advice\" from:#{EmailVerifier::FROM_EMAIL} to:#{EmailVerifier::TO_EMAIL}",
                maxResults: "10000",
              },
            )
            .to_return(body: { resultSizeEstimate: 0 }.to_json, headers: { "Content-Type" => "application/json" })
        end

        it "reports that there is an alert that has not been sent" do
          expect(verifier.have_all_alerts_been_emailed?).to eql(false)
          expect(verifier.missing_alerts.size).to eql(1)
        end
      end
    end

    context "when no emails are sent" do
      before do
        stub_request(:get, "https://gmail.googleapis.com/gmail/v1/users/me/messages")
          .with(query: hash_including(:q))
          .to_return(body: { resultSizeEstimate: 0 }.to_json, headers: { "Content-Type" => "application/json" })
      end

      it "reports that no alerts have been sent" do
        expect(verifier.have_all_alerts_been_emailed?).to eql(false)
        expect(verifier.missing_alerts.size).to eql(6)
      end
    end
  end
end
