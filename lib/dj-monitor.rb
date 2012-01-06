require File.dirname(__FILE__) + "/dj-monitor/version"

module Djmonitor
  require File.dirname(__FILE__) + "/dj-monitor/monitor"
  require File.dirname(__FILE__) + "/dj-monitor/railtie" if defined?(Rails::Railtie)
end
