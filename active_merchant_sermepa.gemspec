# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active_merchant_sermepa}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sam Lown"]
  s.date = %q{2011-02-25}
  s.description = %q{Add support to ActiveMerchant for the Sermepa payment gateway by Servired used by many banks in Spain}
  s.summary = "ActiveMerchant support for Servired's Sermepa payment gateway"
  s.email = %q{me@samlown.com}
  s.extra_rdoc_files = ['MIT-LICENSE', 'CHANGELOG', 'README.rdoc']
  s.homepage = %q{http://github.com/samlown/active_merchant_sermepa}
  s.rubygems_version = "1.3.7"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("activemerchant", ">= 1.9.4")
  s.add_development_dependency("mocha", "~> 0.9.10")
  s.add_development_dependency("money", "~> 3.5.4")
  s.add_development_dependency("actionpack", "~> 3.0.3")

end
