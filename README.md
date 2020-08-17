# Email alert monitor

GOV.UK provides email alerts. This repo provides scripts that verify that
emails have been sent for certain publications.

Currently the script looks at [drug and medical advice
alerts](https://www.gov.uk/drug-device-alerts) and [foreign travel advice
alerts](https://www.gov.uk/foreign-travel-advice).

We validate each email has been sent by Notify
(gov.uk.email@notifications.service.gov.uk) and received by our own
govuk_email_check@digital.cabinet-office.gov.uk email box.

### Medical safety alerts

An email address has been subscribed to these alerts (via [the email signup page](https://www.gov.uk/drug-device-alerts/email-signup)).

Every hour, we look at [the public RSS feed for alerts](https://www.gov.uk/drug-device-alerts.atom). We then check the
email address has received an email for these publications via the
[Google Gmail API](https://developers.google.com/gmail/api/).

### Travel advice alerts

An email address has been subscribed to these alerts (via [the email signup page](https://www.gov.uk/foreign-travel-advice/email-signup)).

Every hour, we look at [the content store feed for alerts](https://www.gov.uk/api/content/foreign-travel-advice). We then
check the email address has received an email for these publications via
the [Google Gmail API](https://developers.google.com/gmail/api/).

## Technical documentation

### Running

`bundle exec rake run_medical_alerts` for the medical safety alert checker

`bundle exec rake run_travel_alerts` for the travel advice alert checker

Both rake tasks will exit normally and not output anything if everything
is OK.

If they find that some alerts have not been sent out, they will print the
missing alerts and exit with a non-zero exit code. When reported to Icinga
by Jenkins, this will alert developers.

### Running the test suite

`bundle exec rspec`

### Testing the alert checks

1. Let 2nd line know that you're testing changes to these alerts.
2. In the inbox (govuk_email_check@digital.cabinet-office.gov.uk) for whichever
   alert type you're checking, delete an email that was received during the
   inspection period. For Medical Safety alerts this is the the 5 most recent
   over an hour old (see [here][medical safety query]) and for Travel Advice
   this is all updates between 150 minutes to 2 days old (see [here][travel
   advice query]). The credentials for the email account are in the 2nd line
   pass store -
   `pass/2ndline/google-accounts/govuk_email_check@digital.cabinet-office.gov.uk`.
3. In production Jenkins, either run the [MedicalSafetyEmailAlertCheck] or
   [TravelAdviceEmailAlertCheck]. This should fail and output an error message
   reporting the absence of the deleted email.
4. Check the alert is triggered correctly in [Icinga].
5. If testing the Travel advice check we would expect PagerDuty to notify
   whoevers on call (in hours this would be the devs on 2nd line).
6. Back in the inbox, restore the email from trash.
7. Rerun the Jenkins job you ran in step 3.
8. Everything should be green.

[medical safety query]: https://github.com/alphagov/email-alert-monitoring/blob/master/lib/email_search/medical_safety.rb#L16-L17
[travel advice query]: https://github.com/alphagov/travel-advice-publisher/blob/master/app/controllers/healthcheck_controller.rb#L25-L26
[MedicalSafetyEmailAlertCheck]: https://deploy.blue.production.govuk.digital/job/medical-safety-email-alert-check/
[TravelAdviceEmailAlertCheck]: https://deploy.blue.production.govuk.digital/job/travel-advice-email-alert-check/
[Icinga]: https://alert.blue.production.govuk.digital/cgi-bin/icinga/status.cgi?host=all&type=detail&servicestatustypes=16&hoststatustypes=3&serviceprops=2097162

### Regenerating Google OAuth credentials

The `GOOGLE_OAUTH_CREDENTIALS` environment variable contains a JSON
representation of the OAuth credentials used to connect to the email
account to check for email alerts.

If these credentials stop working (for example, they are revoked), they
can be regenerated using the following steps:

1. Log in to the Google account that will be checked for email alerts.
   For best results, do this in a private browsing window.
2. Run `bundle exec rake get_oauth_url` to get a Google authorisation
   URL.
3. Visit this URL in the browser window from step 1.
4. Allow permission for this app to log into the relevant email account.
5. The browser will redirect to a non-existent localhost URL - copy the
   contents of the `code` query string parameter from this URL.
6. Run `bundle exec rake get_oauth_token[<code>]`, where `<code>` is
   the code you extracted in step 5.
7. Copy the output of the command and replace the existing credentials
   in [aws production hierdata](https://github.com/alphagov/govuk-secrets/blob/master/puppet_aws/hieradata/production_credentials.yaml).

## Licence

[MIT License](LICENCE.txt)
