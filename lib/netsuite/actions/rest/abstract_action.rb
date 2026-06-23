require 'simple_oauth'

module NetSuite
  module Actions
    module Rest
      class AbstractAction
        def request(credentials={})
          NetSuite::ConfigurationRest.connection(request_uri, request_options, credentials).auth(auth_header).request(http_verb, request_uri, params: request_params, json: request_body.to_json)
        end

        protected

        def auth_header(credentials={})
          header = SimpleOAuth::Header.new(http_verb, NetSuite::ConfigurationRest.endpoint + request_uri, request_options, signature_method: "HMAC-SHA256",realm: credentials[:account] || NetSuite::ConfigurationRest.account, consumer_key: credentials[:consumer_key] || NetSuite::ConfigurationRest.consumer_key, consumer_secret: credentials[:consumer_secret] || NetSuite::ConfigurationRest.consumer_secret, token: credentials[:token_id] || NetSuite::ConfigurationRest.token_id, token_secret: credentials[:token_secret] || NetSuite::ConfigurationRest.token_secret)
          header.to_s
        end

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

        def request_params
          {}
        end

        def soap_header_extra_info
          {}
        end
      end
    end
  end
end
  