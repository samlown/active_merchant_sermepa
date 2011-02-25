# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active_merchant_sermepa}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sam Lown"]
  s.date = %q{2010-12-15}
  s.description = %q{Add support to ActiveMerchant for the Spanish Sermepa payment gateway}
  s.email = %q{me@samlown.com}
  s.extra_rdoc_files = ["CHANGELOG", "README.rdoc", "lib/active_merchant/billing/integrations/sermepa.rb", "lib/active_merchant/billing/integrations/sermepa/helper.rb", "lib/active_merchant/billing/integrations/sermepa/notification.rb", "lib/active_merchant/billing/integrations/sermepa/return.rb", "lib/active_merchant_sermepa.rb"]
  s.files = ["CHANGELOG", "MIT-LICENSE", "Manifest", "README.rdoc", "Rakefile", "active_merchant_sermepa.gemspec", "lib/active_merchant/billing/integrations/sermepa.rb", "lib/active_merchant/billing/integrations/sermepa/helper.rb", "lib/active_merchant/billing/integrations/sermepa/notification.rb", "lib/active_merchant/billing/integrations/sermepa/return.rb", "lib/active_merchant_sermepa.rb", "test/test_helper.rb", "test/unit/integrations/helpers/sermepa_helper_test.rb", "test/unit/integrations/notifications/sermepa_notification_test.rb", "test/unit/integrations/sermepa_module_text.rb"]
  s.homepage = %q{http://github.com/samlown/active_merchant_sermepa}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Active_merchant_sermepa", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{active_merchant_sermepa}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Add support to ActiveMerchant for the Spanish Sermepa payment gateway}
  s.test_files = ["test/unit/integrations/notifications/sermepa_notification_test.rb", "test/unit/integrations/helpers/sermepa_helper_test.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<active_merchant>, [">= 1.9.2"])
    else
      s.add_dependency(%q<active_merchant>, [">= 1.9.2"])
    end
  else
    s.add_dependency(%q<active_merchant>, [">= 1.9.2"])
  end
end
