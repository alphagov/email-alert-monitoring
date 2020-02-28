require "googleauth"
require "google/apis/gmail_v1"

class GoogleAuth
  def self.service
    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = "GOV.UK Email monitoring service"
    service.request_options.retries = 3
    service.authorization = get_credentials
    service
  end

  def self.get_credentials
    client_id = Google::Auth::ClientId.from_hash(
      "installed" => {
        "client_id" => ENV.fetch("GOOGLE_CLIENT_ID"),
        "client_secret" => ENV.fetch("GOOGLE_CLIENT_SECRET"),
      },
    )

    authorizer = Google::Auth::UserAuthorizer.new(
      client_id,
      Google::Apis::GmailV1::AUTH_GMAIL_READONLY,
      DummyEnvironmentTokenStore.new,
    )

    authorizer.get_credentials("default")
  end

  class DummyEnvironmentTokenStore
    def load(_id)
      ENV.fetch("GOOGLE_OAUTH_CREDENTIALS")
    end

    def store(_id, _data)
      # The Google API client expects a "token store" object. This object should
      # return the latest oauth-token credentials, among which a "refresh token"
      # to fetch the oauth token, used for actual requests. It will try to save
      # the new oauth-token by calling this `#store` method. In our case we
      # don't need that token because we are fine by fetching a new oauth-token
      # every time the script is run.
    end
  end
end
