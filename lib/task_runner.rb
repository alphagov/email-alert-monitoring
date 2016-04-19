require "airbrake"

class TaskRunner
  def verify_with_retries(retries: 5, verifier:)
    begin
      tries ||= retries
      verifier.run_report
    rescue => e
      Airbrake.notify(e)
      unless (tries -= 1).zero?
        retry
      end
    else
      yield
    end
  end
end
