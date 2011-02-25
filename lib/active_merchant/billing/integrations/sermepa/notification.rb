# encoding: utf-8
module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module Sermepa
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          include PostsData

          def complete?
            status == 'Completed'
          end 

          def transaction_id
            params['ds_order']
          end

          # When was this payment received by the client. 
          def received_at
            if params['ds_date']
              (day, month, year) = params['ds_date'].split('/')
              Time.parse("#{year}-#{month}-#{day} #{params['ds_hour']}")
            else
              Time.now # Not provided!
            end
          end

          # the money amount we received in cents in X.2 format
          def gross
            sprintf("%.2f", params['ds_amount'].to_f / 100)
          end

          # Was this a test transaction?
          def test?
            false
          end

          def currency
            Sermepa.currency_from_code( params['ds_currency'] ) 
          end

          # Status of transaction. List of possible values:
          # <tt>Completed</tt>
          # <tt>Failed</tt>
          # <tt>Pending</tt>
          def status
            case error_code.to_i
            when 0..99
              'Completed'
            when 900
              'Pending'
            else
              'Failed'
            end
          end

          def error_code
            params['ds_response']
          end

          def error_message
            msg = Sermepa.response_code_message(error_code)
            error_code.to_s + ' - ' + (msg.nil? ? 'Operación Aceptada' : msg)
          end

          def secure_payment?
            params['ds_securepayment'] == '1'
          end

          # Acknowledge the transaction.
          #
          # Validate the details provided by the gateway by ensuring that the signature
          # matches up with the details provided.
          #
          # Optionally, a set of credentials can be provided that should contain a 
          # :secret_key instead of using the global credentials defined in the Sermepa::Helper.
          #
          # Example:
          # 
          #   def notify
          #     notify = Sermepa::Notification.new(request.query_parameters)
          #
          #     if notify.acknowledge
          #       ... process order ... if notify.complete?
          #     else
          #       ... log possible hacking attempt ...
          #     end
          #
          #
          def acknowledge(credentials = nil)
            return false if params['ds_signature'].blank?
            str = 
              params['ds_amount'].to_s +
              params['ds_order'].to_s +
              params['ds_merchantcode'].to_s + 
              params['ds_currency'].to_s +
              params['ds_response'].to_s
            if xml?
              str += params['ds_transactiontype'].to_s + params['ds_securepayment'].to_s
            end

            str += (credentials || Sermepa::Helper.credentials)[:secret_key]
            sig = Digest::SHA1.hexdigest(str)
            sig.upcase == params['ds_signature'].to_s.upcase
          end

          private

          def xml?
            !params['code'].blank?
          end

          # Take the posted data and try to extract the parameters.
          #
          # Posted data can either be a parameters hash, XML string or CGI data string
          # of parameters.
          #
          def parse(post)
            if post.is_a?(Hash)
              post.each { |key, value|  params[key.downcase] = value }
            elsif post.to_s =~ /<retornoxml>/i
              # XML source
              self.params = xml_response_to_hash(@raw)
            else
              for line in post.to_s.split('&')    
                key, value = *line.scan( %r{^([A-Za-z0-9_.]+)\=(.*)$} ).flatten
                params[key.downcase] = CGI.unescape(value)
              end
            end
            @raw = post.inspect.to_s
          end

          def xml_response_to_hash(xml)
            result = { }
            doc = Nokogiri::XML(xml)
            doc.css('RETORNOXML OPERACION').children().each do |child|
              result[child.name.downcase] = child.inner_text
            end
            result['code'] = doc.css('RETORNOXML CODIGO').inner_text
            result
          end
 
        end
      end
    end
  end
end
