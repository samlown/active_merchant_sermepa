require File.dirname(__FILE__) + '/../../test_helper'

class SermepaModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_notification_method
    assert_instance_of Sermepa::Notification, Sermepa.notification('name=cody')
  end

  def test_currency_code
    assert_equal '978', Sermepa.currency_code('EUR')
  end
  def test_currency_from_code
    assert_equal 'EUR', Sermepa.currency_from_code('978')
  end

  def test_language_code
    assert_equal Sermepa.language_code('es'), '001'
    assert_equal Sermepa.language_code('CA'), '003'
    assert_equal Sermepa.language_code(:pt), '009'
  end
  def test_language_from_code
    assert_equal :ca, Sermepa.language_from_code('003')
  end

  def test_transaction_code
    assert_equal '2', Sermepa.transaction_code(:confirmation)
  end
  def test_transaction_from_code
    assert_equal :confirmation, Sermepa.transaction_from_code(2)
  end

  def test_response_code_message
    assert_equal nil, Sermepa.response_code_message(23)
    assert_equal nil, Sermepa.response_code_message('23')
    assert_equal "Tarjeta caducada", Sermepa.response_code_message(101)
  end

end 
