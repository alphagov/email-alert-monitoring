require 'spec_helper'
require_relative './../../lib/drug_alert_email_verifier'

RSpec.describe "Drug email alert verifier" do
  it "Reports if all alerts have been sent via email" do
    given_credentials_for_the_google_api_have_been_set
    and_there_are_drug_advice_alerts
    and_emails_have_been_sent_for_all_alerts
    when_the_verifier_is_run
    then_it_reports_that_all_emails_have_been_sent
  end

  it "Reports if there is an alert that has not been sent" do
    given_credentials_for_the_google_api_have_been_set
    and_there_are_drug_advice_alerts
    and_no_emails_have_been_sent
    when_the_verifier_is_run
    then_it_reports_that_an_email_is_missing
  end

  it "Ignores very new alerts" do
    given_credentials_for_the_google_api_have_been_set
    and_there_is_a_drug_advice_alert_published_very_recently
    and_no_emails_have_been_sent
    when_the_verifier_is_run
    then_it_reports_that_all_emails_have_been_sent
  end

  def given_credentials_for_the_google_api_have_been_set
    set_credentials
  end

  def and_there_are_drug_advice_alerts
    stub_request(:get, "https://www.gov.uk/drug-device-alerts.atom").
      to_return(body: File.read(File.dirname(__FILE__) + "/example_rss_feed.xml"))
  end

  def and_there_is_a_drug_advice_alert_published_very_recently
    rss = File.read(File.dirname(__FILE__) + "/example_rss_feed.xml")

    rss = rss.gsub('2016-02-01T12:58:40+00:00', Time.now.iso8601)

    stub_request(:get, "https://www.gov.uk/drug-device-alerts.atom").
      to_return(body: rss)
  end

  def and_emails_have_been_sent_for_all_alerts
    %w[a@example.org b@example.org].each do |email|
      stub_request(:get, "https://www.googleapis.com/gmail/v1/users/me/messages?q=https://www.gov.uk/drug-device-alerts/an-important-alert%20to:#{email.gsub("+", "%2B")}").
        to_return(body: { resultSizeEstimate: 1 }.to_json, headers: { 'Content-Type' => 'application/json'})

      stub_request(:get, "https://www.googleapis.com/gmail/v1/users/me/messages?q=https://www.gov.uk/drug-device-alerts/another-important-alert%20to:#{email.gsub("+", "%2B")}").
        to_return(body: { resultSizeEstimate: 1 }.to_json, headers: { 'Content-Type' => 'application/json'})
    end
  end

  def and_no_emails_have_been_sent
    %w[a@example.org b@example.org].each do |email|
      stub_request(:get, "https://www.googleapis.com/gmail/v1/users/me/messages?q=https://www.gov.uk/drug-device-alerts/an-important-alert%20to:#{email.gsub("+", "%2B")}").
        to_return(body: { resultSizeEstimate: 0 }.to_json, headers: { 'Content-Type' => 'application/json'})

      stub_request(:get, "https://www.googleapis.com/gmail/v1/users/me/messages?q=https://www.gov.uk/drug-device-alerts/another-important-alert%20to:#{email.gsub("+", "%2B")}").
        to_return(body: { resultSizeEstimate: 0 }.to_json, headers: { 'Content-Type' => 'application/json'})
    end
  end

  def when_the_verifier_is_run
    @verifier = DrugAlertEmailVerifier.new
  end

  def then_it_reports_that_all_emails_have_been_sent
    expect(@verifier.have_all_alerts_been_emailed?).to eql(true)
  end

  def then_it_reports_that_an_email_is_missing
    expect(@verifier.have_all_alerts_been_emailed?).to eql(false)
    expect(@verifier.missing_alerts.size).to eql(4)
  end
end
