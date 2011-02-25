#!/usr/bin/env ruby

require "bundler/setup"
require 'rubygems'

$:.unshift File.expand_path('../../lib', __FILE__)

require 'test/unit'
require 'money'
require 'mocha'
require 'yaml'
require 'active_merchant_sermepa'

require 'action_controller'
require 'action_view/template'
begin
  require 'action_dispatch/testing/test_process'
rescue LoadError
  require 'action_controller/test_process'
end
require 'active_merchant/billing/integrations/action_view_helper'

ActiveMerchant::Billing::Base.mode = :test


## Assertions copied from ActiveMerchant. This is lame, they should have them in a seperate file!

module ActiveMerchant
  module Assertions
    AssertionClass = RUBY_VERSION > '1.9' ? MiniTest::Assertion : Test::Unit::AssertionFailedError
    
    def assert_field(field, value)
      clean_backtrace do
        assert_equal value, @helper.fields[field]
      end
    end
    
    # Allows the testing of you to check for negative assertions:
    #
    # # Instead of
    # assert !something_that_is_false
    #
    # # Do this
    # assert_false something_that_should_be_false
    #
    # An optional +msg+ parameter is available to help you debug.
    def assert_false(boolean, message = nil)
      message = build_message message, '<?> is not false or nil.', boolean
    
      clean_backtrace do
        assert_block message do
          not boolean
        end
      end
    end
    
    # A handy little assertion to check for a successful response:
    #
    # # Instead of
    # assert_success response
    #
    # # DRY that up with
    # assert_success response
    #
    # A message will automatically show the inspection of the response
    # object if things go afoul.
    def assert_success(response)
      clean_backtrace do
        assert response.success?, "Response failed: #{response.inspect}"
      end
    end
    
    # The negative of +assert_success+
    def assert_failure(response)
      clean_backtrace do
        assert_false response.success?, "Response expected to fail: #{response.inspect}"
      end
    end
    
    def assert_valid(validateable)
      clean_backtrace do
        assert validateable.valid?, "Expected to be valid"
      end
    end
    
    def assert_not_valid(validateable)
      clean_backtrace do
        assert_false validateable.valid?, "Expected to not be valid"
      end
    end
    
    private
    def clean_backtrace(&block)
      yield
    rescue AssertionClass => e
      path = File.expand_path(__FILE__)
      raise AssertionClass, e.message, e.backtrace.reject { |line| File.expand_path(line) =~ /#{path}/ }
    end
  end
end

Test::Unit::TestCase.class_eval do
  include ActiveMerchant::Assertions
end

