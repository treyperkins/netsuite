# https://system.netsuite.com/help/helpcenter/en_US/Output/Help/SuiteCloudCustomizationScriptingWebServices/SuiteTalkWebServices/get.html
module NetSuite
  module Actions
    module Rest
      class Get < AbstractAction
        include Support::Requests

        def initialize(klass, options = {})
          @klass   = klass
          @options = options
        end

        private

        def request_body
          nil
        end

        def success?
          @success ||= response_hash[:status][:@is_success] == 'true'
        end

        def response_body
          @response_body ||= response_hash[:record]
        end

        def response_hash
          @response_hash = @response.body[:get_response][:read_response]
        end

        def request_options
          {
          }
        end

        def request_uri
          "#{NetSuite::Support::Records.netsuite_type(@klass)}/#{@options[:internal_id]}"
        end

        def action_name
          :get
        end

        module Support

          def self.included(base)
            base.extend(ClassMethods)
          end

          module ClassMethods

            def get(options = {}, credentials = {})
              options = { :internal_id => options } unless options.is_a?(Hash)

              response = NetSuite::Actions::Rest::Get.call([self, options], credentials)
              if response.success?
              new(response.body)
              else
              raise RecordNotFound, "#{self} with OPTIONS=#{options.inspect} could not be found"
              end
            end

          end
        end

      end
    end
  end
end
