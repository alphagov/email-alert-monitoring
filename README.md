# Email alert monitor

GOV.UK provides email alerts. This repo provides scripts that verify that emails have been sent for certain publications.

### Drug and medical advice alerts

Currently the script only looks at the [drug and medical advice alerts](https://www.gov.uk/drug-device-alerts). Monitoring for other types of alerts may be added.

To test that all of these alerts are sent to email subscribers, we've subscribed a number of email addresses to these publications (via [its email-signup page](https://www.gov.uk/drug-device-alerts/email-signup)).

Every hour we look at [the public RSS feed for alerts](https://www.gov.uk/drug-device-alerts.atom). We then check our email address has received an email for these publications via the [Google Gmail API](https://developers.google.com/gmail/api/).

Note that drug alerts are so important that they have a special "urgent" flag in GovDelivery (this is set in the payload [specialist-publisher](https://github.com/alphagov/specialist-publisher) sends to
[email-alert-api](https://github.com/alphagov/email-alert-api)). This means that even if somebody has requested a weekly or daily digested email for these alerts, they should receive the emails immediately. To tests this, we've subscribed three different email addresses to the alerts (for weekly digest, daily digest and immediately). In production `EMAILS_THAT_SHOULD_RECEIVE_DRUG_ALERTS` env var contains these three email addresses.

## Technical documentation

### Running

`bundle exec rake run`

This rake task will exit normally and not output anything if everything is okay.

If it finds that some alerts have not been sent out, it will print the missing alerts and exit with a nonzero exit code. When run by Icinga, this will alert developers that something is wrong.

### Running the test suite

`bundle exec rspec`

## Licence

[MIT License](LICENCE.txt)
