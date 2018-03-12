require "govuk_app_config"

class TaskRunner
  def verify_with_retries(retries: 5, verifier:)
    begin
      tries ||= retries
      verifier.run_report
    rescue StandardError => e
      GovukError.notify(e)
      unless (tries -= 1).zero?
        retry
      end
    else
      yield
    end
  end
end
