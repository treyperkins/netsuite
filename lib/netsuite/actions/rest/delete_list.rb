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

        def request_body
          nil
        end

        # get the location of the background processing request from the response header, which can be used to check the status of the request and retrieve any errors
        def response_location
          @response.headers['Location']
        end

        def success?
          @success ||= response_errors.blank?
        end

        # This has NOT been adapted to the new REST API response format, and is currently non-functional. It needs to be reimplemented to return a hash of internal_id => [errors]
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
          "record/v1/#{NetSuite::Support::Records.netsuite_type(@klass)}?ids=#{id_list.join(',')}"
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
          @response_body ||= response_location
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
