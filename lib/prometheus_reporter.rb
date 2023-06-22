require "prometheus/client"
require "prometheus/client/push"

class PrometheusReporter
  def initialize(name)
    @name = name
    @registry = Prometheus::Client.registry
  end

  def record_successful_run
    successful_run = Prometheus::Client::Gauge.new(symbol, docstring: "Time of last run where no missing emails were detected")
    successful_run.set_to_current_time
    @registry.register(successful_run)
  end

  def symbol
    "#{@name}_last_successful_run_timestamp_seconds".to_sym
  end

  def push
    Prometheus::Client::Push.new(job: "email-alert-monitoring", gateway: ENV.fetch("PROMETHEUS_PUSHGATEWAY_URL")).add(@registry)
  end
end
