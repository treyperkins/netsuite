module NetSuite
  module Actions
    module Rest
      class AbstractAction
        def request(credentials={})
          NetSuite::ConfigurationRest.connection(request_options, credentials).request(http_verb, request_uri, body: request_body)
        end

        protected

        def action_name
          raise NotImplementedError, 'Not implemented on abstract class'
        end
        
        def http_verb
          raise NotImplementedError, 'Not implemented on abstract class'
        end

        def initialize
          raise NotImplementedError, 'Not implemented on abstract class'
        end

        def request_body
          raise NotImplementedError, 'Not implemented on abstract class'
        end

        def request_uri
          raise NotImplementedError, 'Not implemented on abstract class'
        end

        def request_options
          {}
        end

        def soap_header_extra_info
          {}
        end
      end
    end
  end
end
  