# Regenerating Google OAuth credentials

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
   in [production hieradata](https://github.com/alphagov/govuk-secrets/blob/master/puppet/hieradata/production_credentials.yaml).
