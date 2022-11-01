require "spec_helper"
require_relative "./../../lib/task_runner"

RSpec.describe TaskRunner do
  describe "#verify_with_retries" do
    let(:verifier) { double }

    context "when the verifier raises an exception" do
      before { allow(verifier).to receive(:run_report).and_raise(StandardError) }

      it "tells GovukError and retries the specified number of times" do
        expect(verifier).to receive(:run_report).exactly(3).times
        expect(GovukError).to receive(:notify).with(StandardError).exactly(3).times
        @verified = false

        def run_verify_with_retries
          TaskRunner.new.verify_with_retries(retries: 3, verifier: verifier) do
            @verified = true
          end
        end

        expect { run_verify_with_retries }.to raise_error(StandardError)

        expect(@verified).to be false
      end
    end

    context "when the verifier is successful" do
      before { allow(verifier).to receive(:run_report) }

      it "yields to the given block" do
        expect(verifier).to receive(:run_report).exactly(1).times
        expect(GovukError).to_not receive(:notify)
        verified = false

        TaskRunner.new.verify_with_retries(retries: 3, verifier: verifier) do
          verified = true
        end

        expect(verified).to be true
      end
    end
  end
end
