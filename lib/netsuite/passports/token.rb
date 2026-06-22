module NetSuite
  module Passports
    class Token
      attr_reader :account, :consumer_key, :consumer_secret, :token_id, :token_secret

      def initialize(account, consumer_key, consumer_secret, token_id, token_secret)
        @account = account.to_s
        @consumer_key = consumer_key
        @consumer_secret = consumer_secret
        @token_id = token_id
        @token_secret = token_secret
      end

      def passport
        {
          'platformMsgs:tokenPassport' => {
            'platformCore:account' => account,
            'platformCore:consumerKey' => consumer_key,
            'platformCore:token' => token_id,
            'platformCore:nonce' => nonce,
            'platformCore:timestamp' => timestamp,
            'platformCore:signature' => signature,
            :attributes! => { 'platformCore:signature' => { 'algorithm' => 'HMAC-SHA256' } }
          }
        }
      end

      def header
        parts = {
          "realm" => URI.encode_uri_component(account),
          "oauth_consumer_key" => URI.encode_uri_component(consumer_key),
          "oauth_token" => URI.encode_uri_component(token_id),
          "oauth_signature_method" => URI.encode_uri_component("HMAC-SHA256"),
          "oauth_timestamp" => URI.encode_uri_component(timestamp),
          "oauth_nonce" => URI.encode_uri_component(nonce),
          "oauth_version" => URI.encode_uri_component("1.0"),
          "oauth_signature" => URI.encode_uri_component(signature),
        }
        "OAuth " + parts.map { |k, v| "#{k}=\"#{v}\"" }.join(", ")
      end

      private

      def signature
        Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), signature_key, signature_data))
      end

      def signature_key
        "#{consumer_secret}&#{token_secret}"
      end

      def signature_data
        "#{account}&#{consumer_key}&#{token_id}&#{nonce}&#{timestamp}"
      end

      def nonce
        @nonce ||= Array.new(20) { alphanumerics.sample }.join
      end

      def alphanumerics
        [*'0'..'9',*'A'..'Z',*'a'..'z']
      end

      def timestamp
        @timestamp ||= Time.now.to_i
      end
    end
  end
end
