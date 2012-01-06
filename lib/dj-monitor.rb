require File.dirname(__FILE__) + "/dj-monitor/version"

module djmonitor
  require File.dirname(__FILE__) + "/dj-monitor/monitor"
  require File.dirname(__FILE__) + "/dj-monitor/railtie" if defined?(Rails::Railtie)
end
