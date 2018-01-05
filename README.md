# Email alert monitor

GOV.UK provides email alerts. This repo provides scripts that verify that
emails have been sent for certain publications.

Currently the script only looks at the [drug and medical advice
alerts](https://www.gov.uk/drug-device-alerts) and [foreign travel advice
alerts](https://www.gov.uk/foreign-travel-advice). Monitoring for other types
of alerts may be added.

### Drug and medical advice alerts

To test that all drug and device alerts are sent to email subscribers, we've
subscribed a number of email addresses to these publications (via [its
email-signup page](https://www.gov.uk/drug-device-alerts/email-signup)).

Every hour we look at [the public RSS feed for
alerts](https://www.gov.uk/drug-device-alerts.atom). We then check our email
address has received an email for these publications via the [Google Gmail
API](https://developers.google.com/gmail/api/).

Note that drug alerts are so important that they have a special "urgent" flag
in GovDelivery (this is set in the payload
[specialist-publisher](https://github.com/alphagov/specialist-publisher) sends
to [email-alert-api](https://github.com/alphagov/email-alert-api)). This means
that even if somebody has requested a weekly or daily digested email for these
alerts, they should receive the emails immediately. To tests this, we've
subscribed three different email addresses to the alerts (for weekly digest,
daily digest and immediately). In production
`EMAILS_THAT_SHOULD_RECEIVE_DRUG_ALERTS` env var contains these three email
addresses.

### Travel advice alerts

An email address has also been subscribed to the "Travel advice for all
countries" [alerts](https://www.gov.uk/foreign-travel-advice/email-signup).
Since there is no special casing for digests for these alerts, only a single
email is used. The `EMAILS_THAT_SHOULD_RECEIVE_TRAVEL_ADVICE_ALERTS` env var is
used to determine the addresses to query.

The monitoring for these alerts looks at the [Content Store JSON
feed](https://www.gov.uk/api/content/foreign-travel-advice).

## Technical documentation

### Running

`bundle exec rake run` for the drug device alert checker

`bundle exec rake run_travel_alerts` for the travel advice alert checker

Both rake tasks will exit normally and not output anything if everything is
okay.

If they find that some alerts have not been sent out, they will print the
missing alerts and exit with a nonzero exit code. When run by Icinga, this will
alert developers that something is wrong.

### Running the test suite

`bundle exec rspec`

## Licence

[MIT License](LICENCE.txt)
