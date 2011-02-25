# encoding: utf-8
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Sermepa
        # Sermepa/Servired Spanish Virtual POS Gateway
        #
        # Support for the Spanish payment gateway provided by Sermepa, part of Servired,
        # one of the main providers in Spain to Banks and Cajas.
        #
        # Requires the :terminal_id, :commercial_id, and :secret_key to be set in the credentials
        # before the helper can be used. Credentials may be overwriten when instantiating the helper
        # if required or instead of the global variable. Optionally, the :key_type can also be set to 
        # either 'sha1_complete' or 'sha1_extended', where the later is the default case. This
        # is a configurable option in the Sermepa admin which you may or may not be able to access.
        # If nothing seems to work, try changing this.
        #
        # Ensure the gateway is configured correctly. Synchronization should be set to Asynchronous
        # and the parameters in URL option (Parámetros en las URLs) should be set to true unless
        # the notify_url is provided. During development on localhost ensuring this option is set
        # is especially important as there is no other way to confirm a successful purchase.
        #
        # Your view for a payment form might look something like the following:
        #
        #   <%= payment_service_for @transaction.id, 'Company name', :amount => @transaction.amount, :currency => 'EUR', :service => :sermepa do |service| %>
        #     <% service.description     @sale.description %>
        #     <% service.customer_name   @sale.client.name %>
        #     <% service.notify_url      notify_sale_url(@sale) %>
        #     <% service.success_url     win_sale_url(@sale) %>
        #     <% service.failure_url     fail_sale_url(@sale) %>
        #    
        #     <%= submit_tag "PAY!" %>
        #   <% end %>
        #
        #
        # 
        class Helper < ActiveMerchant::Billing::Integrations::Helper
          include PostsData

          class << self
            # Credentials should be set as a hash containing the fields:
            #  :terminal_id, :commercial_id, :secret_key, :key_type (optional)
            attr_accessor :credentials
          end

          mapping :account,     'Ds_Merchant_MerchantName'

          mapping :currency,    'Ds_Merchant_Currency'
          mapping :amount,      'Ds_Merchant_Amount'

          mapping :order,       'Ds_Merchant_Order'
          mapping :description, 'Ds_Merchant_ProductDescription'
          mapping :client,      'Ds_Merchant_Titular'

          mapping :notify_url,  'Ds_Merchant_MerchantURL'
          mapping :success_url, 'Ds_Merchant_UrlOK'
          mapping :failure_url, 'Ds_Merchant_UrlKO'

          mapping :language,    'Ds_Merchant_ConsumerLanguage'

          mapping :transaction_type, 'Ds_Merchant_TransactionType'

          mapping :customer_name, 'Ds_Merchant_Titular' 

          #### Special Request Specific Fields ####
          mapping :signature,   'Ds_Merchant_MerchantSignature'
          ########

          # ammount should always be provided in cents!
          def initialize(order, account, options = {})
            self.credentials = options.delete(:credentials) if options[:credentials]
            super(order, account, options)

            add_field 'Ds_Merchant_MerchantCode', credentials[:commercial_id]
            add_field 'Ds_Merchant_Terminal', credentials[:terminal_id]
            #add_field mappings[:transaction_type], '0' # Default Transaction Type
            self.transaction_type = :authorization
          end

          # Allow credentials to be overwritten if needed
          def credentials
            @credentials || self.class.credentials
          end
          def credentials=(creds)
            @credentials = (self.class.credentials || {}).dup.merge(creds)
          end

          def amount=(money)
            cents = money.respond_to?(:cents) ? money.cents : money
            if money.is_a?(String) || cents.to_i <= 0
              raise ArgumentError, 'money amount must be either a Money object or a positive integer in cents.'
            end
            add_field mappings[:amount], cents.to_i
          end

          def order=(order_id)
            order_id = order_id.to_s
            if order_id !~ /^[0-9]{4}/ && order_id.length <= 8
              order_id = ('0' * 4) + order_id
            end
            regexp = /^[0-9]{4}[0-9a-zA-Z]{0,8}$/
            raise "Invalid order number format! First 4 digits must be numbers" if order_id !~ regexp
            add_field mappings[:order], order_id
          end

          def currency=( value )
            add_field mappings[:currency], Sermepa.currency_code(value) 
          end

          def language=(lang)
            add_field mappings[:language], Sermepa.language_code(lang)
          end

          def transaction_type=(type)
            add_field mappings[:transaction_type], Sermepa.transaction_code(type)
          end

          def form_fields
            add_field mappings[:signature], sign_request
            @fields
          end


          # Send a manual request for the currently prepared transaction.
          # This is an alternative to the normal view helper and is useful
          # for special types of transaction.
          def send_transaction
            body = build_xml_request

            headers = { }
            headers['Content-Length'] = body.size.to_s
            headers['User-Agent'] = "Active Merchant -- http://activemerchant.org"
            headers['Content-Type'] = 'application/x-www-form-urlencoded'
  
            # Return the raw response data
            ssl_post(Sermepa.operations_url, "entrada="+CGI.escape(body), headers)
          end

          protected

          def build_xml_request
            xml = Builder::XmlMarkup.new :indent => 2
            xml.DATOSENTRADA do
              xml.DS_Version 0.1
              xml.DS_MERCHANT_CURRENCY @fields['Ds_Merchant_Currency']
              xml.DS_MERCHANT_AMOUNT @fields['Ds_Merchant_Amount']
              xml.DS_MERCHANT_MERCHANTURL @fields['Ds_Merchant_MerchantURL']
              xml.DS_MERCHANT_TRANSACTIONTYPE @fields['Ds_Merchant_TransactionType']
              xml.DS_MERCHANT_MERCHANTDATA @fields['Ds_Merchant_Product_Description']
              xml.DS_MERCHANT_TERMINAL credentials[:terminal_id]
              xml.DS_MERCHANT_MERCHANTCODE credentials[:commercial_id]
              xml.DS_MERCHANT_ORDER @fields['Ds_Merchant_Order']
              xml.DS_MERCHANT_MERCHANTSIGNATURE sign_request
            end
            xml.target!
          end


          # Generate a signature authenticating the current request.
          # Values included in the signature are determined by the the type of 
          # transaction.
          def sign_request
            str = @fields['Ds_Merchant_Amount'].to_s +
                  @fields['Ds_Merchant_Order'].to_s +
                  @fields['Ds_Merchant_MerchantCode'].to_s +
                  @fields['Ds_Merchant_Currency'].to_s

            case Sermepa.transaction_from_code(@fields['Ds_Merchant_TransactionType'])
            when :recurring_transaction
              str += @fields['Ds_Merchant_SumTotal']
            end

            if credentials[:key_type].blank? || credentials[:key_type] == 'sha1_extended'
              str += @fields['Ds_Merchant_TransactionType'].to_s +
                     @fields['Ds_Merchant_MerchantURL'].to_s # may be blank!
            end

            str += credentials[:secret_key]

            Digest::SHA1.hexdigest(str)
          end

        end
      end
    end
  end
end
