module NetSuite
  module ConfigurationRest
    extend self

    def reset!
      NetSuite::Utilities.clear_cache!

      attributes.clear
    end

    def attributes
      if multi_tenant?
        Thread.current[:netsuite_gem_attributes] ||= {}
      else
        @attributes ||= {}
      end
    end

    def connection(params={}, credentials={})
      client = HTTP::Client.new(**http_params(params, credentials)).auth(auth_header(credentials))
    end

    def http_params(params={}, credentials={})
      full_params = {
        base_uri: endpoint,
        timeout_options: {read_timeout: read_timeout },
        keep_alive_timeout: open_timeout,
        proxy: proxy,
      }
      full_params.update(params)
      full_params[:timeout_options].update(write_timeout: write_timeout) if supports_write_timeout?
      full_params
    end


    def filters(list = nil)
      if list
        self.filters = list
      else
        attributes[:filters] ||= [
          :password,
          :email,
          :consumerKey,
          :token
        ]
      end
    end

    def filters=(list)
      attributes[:filters] = list
    end

    def rest_domain(rest_domain = nil)
      if rest_domain
        self.rest_domain = rest_domain
      else
        # if sandbox, this parameter is ignored
        if sandbox
          'webservices.sandbox.netsuite.com'
        else
          attributes[:rest_domain] ||= 'webservices.netsuite.com'
        end
      end
    end

    def rest_domain=(rest_domain)
      attributes[:rest_domain] = rest_domain
    end

    def api_version(version = nil)
      if version
        self.api_version = version
      else
        attributes[:api_version] ||= '2016_2'
      end
    end

    def api_version=(version)
      attributes[:api_version] = version
    end

    def endpoint=(endpoint)
      attributes[:endpoint] = endpoint
    end

    def endpoint(endpoint=nil)
      if endpoint
        self.endpoint = endpoint
      else
        attributes[:endpoint]
      end
    end

    def sandbox=(flag)
      attributes[:sandbox] = flag
    end

    def sandbox(flag = nil)
      if flag.nil?
        attributes[:sandbox] ||= false
      else
        self.sandbox = flag
      end
    end

    def sandbox?
      !!sandbox
    end

    def auth_header(credentials={})
      token_auth(credentials)
    end

    def token_auth(credentials)
      NetSuite::Passports::Token.new(
        credentials[:account] || account,
        credentials[:consumer_key] || consumer_key,
        credentials[:consumer_secret] || consumer_secret,
        credentials[:token_id] || token_id,
        credentials[:token_secret] || token_secret
      ).header
    end

    def role=(role)
      attributes[:role] = role
    end

    def role(role = nil)
      if role
        self.role = role
      else
        attributes[:role] ||= '3'
      end
    end

    def email=(email)
      attributes[:email] = email
    end

    def email(email = nil)
      if email
        self.email = email
      else
        attributes[:email]
      end
    end

    def password=(password)
      attributes[:password] = password
    end

    def password(password = nil)
      if password
        self.password = password
      else
        attributes[:password]
      end
    end

    def account=(account)
      attributes[:account] = account
    end

    def account(account = nil)
      if account
        self.account = account
      else
        attributes[:account]
      end
    end

    def consumer_key=(consumer_key)
      attributes[:consumer_key] = consumer_key
    end

    def consumer_key(consumer_key = nil)
      if consumer_key
        self.consumer_key = consumer_key
      else
        attributes[:consumer_key]
      end
    end

    def consumer_secret=(consumer_secret)
      attributes[:consumer_secret] = consumer_secret
    end

    def consumer_secret(consumer_secret = nil)
      if consumer_secret
        self.consumer_secret = consumer_secret
      else
        attributes[:consumer_secret]
      end
    end

    def token_id=(token_id)
      attributes[:token_id] = token_id
    end

    def token_id(token_id = nil)
      if token_id
        self.token_id = token_id
      else
        attributes[:token_id]
      end
    end

    def token_secret=(token_secret)
      attributes[:token_secret] = token_secret
    end

    def token_secret(token_secret = nil)
      if token_secret
        self.token_secret = token_secret
      else
        attributes[:token_secret]
      end
    end

    def read_timeout=(timeout)
      attributes[:read_timeout] = timeout
    end

    def read_timeout(timeout = nil)
      if timeout
        self.read_timeout = timeout
      else
        attributes[:read_timeout] ||= 60
      end
    end

    def open_timeout=(timeout)
      attributes[:open_timeout] = timeout
    end

    def open_timeout(timeout = nil)
      if timeout
        self.open_timeout = timeout
      else
        attributes[:open_timeout]
      end
    end

    def write_timeout=(timeout)
      write_timeout_not_supported! unless supports_write_timeout?
      attributes[:write_timeout] = timeout
    end

    def write_timeout(timeout = nil)
      if timeout
        write_timeout_not_supported! unless supports_write_timeout?
        self.write_timeout = timeout
      else
        attributes[:write_timeout]
      end
    end

    def log=(path)
      attributes[:log] = path
    end

    def log(path = nil)
      self.log = path if path
      attributes[:log]
    end

    def logger(value = nil)
      if value.nil?
        # if passed a IO object (like StringIO) `empty?` won't exist
        valid_log = log && !(log.respond_to?(:empty?) && log.empty?)

        attributes[:logger] ||= ::Logger.new(valid_log ? log : $stdout)
      else
        attributes[:logger] = value
      end
    end

    def logger=(value)
      attributes[:logger] = value
    end

    def silent(value=nil)
      self.silent = value if !value.nil?
      attributes[:silent]
    end

    def silent=(value)
      attributes[:silent] ||= value
    end

    def log_level(value = nil)
      self.log_level = value if value

      attributes[:log_level] || :debug
    end

    def log_level=(value)
      attributes[:log_level] = value
    end

    def proxy=(proxy)
      attributes[:proxy] = proxy
    end

    def proxy(proxy = nil)
      if proxy
        self.proxy = proxy
      else
        attributes[:proxy]
      end
    end

    def multi_tenant!
      @multi_tenant = true
    end

    def multi_tenant?
      @multi_tenant
    end

    private

    def supports_write_timeout?
      Savon::VERSION >= "2.13.0"
    end

    def write_timeout_not_supported!
      fail(ConfigurationError, "Savon doesn't support write_timeout until version 2.13.0")
    end
  end
end
