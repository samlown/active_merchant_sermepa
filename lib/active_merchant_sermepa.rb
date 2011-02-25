
require 'active_merchant'

module ActiveMerchant
  module Billing
    module Integrations
      autoload :Sermepa, 'active_merchant/billing/integrations/sermepa'
    end
  end
end
