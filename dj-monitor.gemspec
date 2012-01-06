# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dj-monitor/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["David Westerink"]
  gem.email         = ["davidakachaos@gmail.com"]
  gem.description   = %q{Monitors the status of your Delayed Jobs.}
  gem.summary       = %q{This project is based on delayed_job-monitor from Michael Guterl. Thanks!}
  gem.homepage      = "https://github.com/davidakachaos/DJMonitor"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "dj-monitor"
  gem.require_paths = ["lib"]
  gem.version       = Djmonitor::VERSION

  gem.add_development_dependency "rspec"
  gem.add_dependency(%q<sequel>, ["~> 3.12.1"])
  gem.add_dependency(%q<pony>, ["~> 1.0.0"])
end
