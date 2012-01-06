require File.dirname(__FILE__) + "/DJMonitor/version"

module DJMonitor
  require File.dirname(__FILE__) + "/DJMonitor/monitor"
  require File.dirname(__FILE__) + "/DJMonitor/railtie" if defined?(Rails::Railtie)
end
