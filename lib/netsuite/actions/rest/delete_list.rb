module NetSuite
  module Actions
    module Rest
      class DeleteList < AbstractAction
        include Support::Requests

        def initialize(klass, options = { })
          @klass = klass
          @options = options
        end

        private

        # <soap:Body>
        #   <platformMsgs:deleteList>
        #     <platformMsgs:baseRef internalId="1" type="customer" xsi:type="platformCore:RecordRef"/>
        #     <platformMsgs:baseRef internalId="2" type="customer" xsi:type="platformCore:RecordRef"/>
        #   </platformMsgs:deleteList>
        # </soap:Body>
        def request_body
          # list = @options.is_a?(Hash) ? @options[:list] : @options

          # formatted_list = if @options[:type_id]
          #   type_id = @options[:type_id]
          #   record_type = 'platformCore:CustomRecordRef'

          #   list.map do |internal_id|
          #     {
          #       '@internalId' => internal_id,
          #       '@typeId' => type_id,
          #       '@xsi:type' => record_type
          #     }
          #   end
          # else
          #   type = NetSuite::Support::Records.netsuite_type(@klass)
          #   record_type = 'platformCore:RecordRef'

          #   list.map do |internal_id|
          #     {
          #       '@internalId' => internal_id,
          #       '@type' => type,
          #       '@xsi:type' => record_type
          #     }
          #   end
          # end

          # {
          #   baseRef: formatted_list
          # }
          nil
        end

        def response_list
          [@response.headers['Location']]
        end

        def success?
          @success ||= response_errors.blank?
        end

        def response_errors
          if response_list.any? { |r| r[:status][:@is_success] == 'false' }
            @response_errors ||= errors
          end
        end

        def request_options
          {
            headers: {
              Prefer: 'respond-async'
            }
          }
        end

        def id_list
          list = @options.is_a?(Hash) ? @options[:list] : @options

          list.map do |internal_id|
            internal_id.to_s
          end
        end

        def request_uri
          "#{NetSuite::Support::Records.netsuite_type(@klass)}?ids=#{id_list.join(',')}"
        end

        def action_name
          :delete_list
        end

        def http_verb
          :delete
        end

        # TODO reimplement this method to return a hash of internal_id => [errors]
        def errors
          # errors = response_list.select { |r| r[:status] && r[:status][:status_detail] }.map do |obj|
          #   error_obj = obj[:status][:status_detail]
          #   error_obj = [error_obj] if error_obj.class == Hash
          #   errors = error_obj.map do |error|
          #     NetSuite::Error.new(error)
          #   end

          #   [obj[:base_ref][:@internal_id], errors]
          # end
          # Hash[errors]
        end

        def response_body
          @response_body ||= response_list
        end

        module Support
          def self.included(base)
            base.extend(ClassMethods)
          end

          module ClassMethods
            def delete_list(options = { }, credentials={})
              response = NetSuite::Actions::Rest::DeleteList.call([self, options], credentials)
            end
          end
        end
      end
    end
  end
end
