require File.expand_path('../../../../test_helper', __FILE__)

class SermepaNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    Sermepa::Helper.credentials = {
        :terminal_id => '1',
        :commercial_id => '999008881',
        :secret_key => 'qwertyasdf0123456789'
    }
    @sermepa = Sermepa::Notification.new(raw_params_data)
  end

  def test_accessors
    assert @sermepa.complete?
    assert_equal "Completed", @sermepa.status
    assert_equal "070820124150", @sermepa.transaction_id
    assert_equal "0.45", @sermepa.gross
    assert_equal "EUR", @sermepa.currency
    assert_equal Time.parse("2007-08-20 12:47"), @sermepa.received_at
  end

  def test_compositions
    assert_equal Money.new(45, 'EUR'), @sermepa.amount
  end

  def test_respond_to_acknowledge
    assert @sermepa.respond_to?(:acknowledge)
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement    
    assert @sermepa.acknowledge
  end

  def test_acknowledgement_with_xml
    # Fake the presence of xml!
    @sermepa.params['code'] = '123'
    @sermepa.params["ds_signature"] = "49A8A907D86FE4763890180061E7907589DBE96A"
    assert @sermepa.acknowledge
  end

  private
  def raw_params_data
    {
      "Ds_AuthorisationCode" => "004022",
      "Ds_SecurePayment" => "1",
      "Ds_Hour" => "12:47",
      "Ds_MerchantData" => "",
      "Ds_Terminal" => "001",
      "Ds_Card_Country" => "724",
      "Ds_Response" => "0000",
      "Ds_Currency" => "978",
      "Ds_MerchantCode" => "999008881",
      "Ds_ConsumerLanguage" => "1",
      "Ds_TransactionType" => "0",
      "Ds_Signature" => "E2E5A14D690B869183CF3BA36E2B6005BB21F9C5",
      "Ds_Order" => "070820124150",
      "Ds_Amount" => "45",
      "Ds_Date" => "20/08/2007"
    }
  end
end
