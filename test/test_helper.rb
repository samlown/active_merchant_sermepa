#!/usr/bin/env ruby
$:.unshift File.expand_path('../../lib', __FILE__)

require 'rubygems'
require 'test/unit'
require 'money'
require 'mocha'
require 'yaml'
require 'active_merchant'
require 'active_merchant_sermepa'

require 'action_controller'
begin
  require 'action_dispatch/testing/test_process'
rescue LoadError
  require 'action_controller/test_process'
end
require 'active_merchant/billing/integrations/action_view_helper'

ActiveMerchant::Billing::Base.mode = :test

