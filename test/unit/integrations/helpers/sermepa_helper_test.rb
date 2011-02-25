require File.dirname(__FILE__) + '/../../../test_helper'

class SermepaHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    Sermepa::Helper.credentials = {
        :terminal_id => '9',
        :commercial_id => '999008881',
        :secret_key => 'qwertyasdf0123456789'
    }
    @helper = Sermepa::Helper.new('070803113316', 'Comercio Pruebas', :amount => 825, :currency => 'EUR')
    @helper.description = "Alfombrilla para raton"
    @helper.customer_name = "Sermepa"
    @helper.notify_url = "https://sis-t.sermepa.es:25443/sis/pruebaCom.jsp"
  end

  def test_credentials_accessible
    assert_instance_of Hash, @helper.credentials
  end

  def test_credentials_overwritable
    @helper = Sermepa::Helper.new(29292929, 'cody@example.com', :amount => 1235, :currency => 'EUR', 
                                 :credentials => {:terminal_id => 12})
    assert_field 'Ds_Merchant_Terminal', '12'
  end

  def test_basic_helper_fields
    assert_field 'Ds_Merchant_MerchantCode', '999008881'
    assert_field 'Ds_Merchant_Amount', '825'
    assert_field 'Ds_Merchant_Order', '070803113316'
    assert_field 'Ds_Merchant_ProductDescription', 'Alfombrilla para raton'
    assert_field 'Ds_Merchant_Currency', '978'
    assert_field 'Ds_Merchant_TransactionType', '0'
    assert_field 'Ds_Merchant_MerchantName', 'Comercio Pruebas'
  end
  
  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end
  
  def test_padding_on_order_id
    @helper.order = 101
    assert_field 'Ds_Merchant_Order', "0000101"
  end

  def test_no_padding_on_valid_order_id
    @helper.order = 1010
    assert_field 'Ds_Merchant_Order', "1010"
  end

  def test_error_raised_on_invalid_order_id
    assert_raise RuntimeError do
      @helper.order = "A0000000ABC"
    end
  end

  def test_basic_signing_request
    assert sig = @helper.send(:sign_request)
    assert_equal "ca2bd747d365b4f0a87c670b270cc390b79670ce", sig
  end

  def test_build_xml_confirmation_request
    # This also tests signing the request for differnet transactions
    data = @helper.send(:build_xml_request)
    assert data =~ /<DS_MERCHANT_TRANSACTIONTYPE>0<\/DS_MERCHANT_TRANSACTIONTYPE>/
    assert data =~ /<DS_MERCHANT_MERCHANTCODE>999008881<\/DS_MERCHANT_MERCHANTCODE>/
    assert data =~ /<DS_MERCHANT_MERCHANTSIGNATURE>ca2bd747d365b4f0a87c670b270cc390b79670ce<\/DS_MERCHANT_MERCHANTSIGNATURE>/
  end

end
