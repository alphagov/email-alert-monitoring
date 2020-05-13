require "govuk_app_config"

class TaskRunner
  def verify_with_retries(retries: 5, verifier:)
    tries ||= retries
    verifier.run_report
  rescue StandardError => e
    GovukError.notify(e)
    retry unless (tries -= 1).zero?
    raise
  else
    yield
  end
end
