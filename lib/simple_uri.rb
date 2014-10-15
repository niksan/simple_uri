require 'logger'
require 'uri'
require 'net/http'
require 'openssl'
require 'active_support/inflector'

module SimpleUri

  class << self

    @@debug_mode = false

    #parameters:url-String, method-Symbol||String, params-String, user-String, password:String, debug-Boolean
    def connect(url: nil, method: nil, params: nil, user: nil, password: nil, debug: @@debug_mode)
      enable_debug_mode(debug)
      uri = URI.parse(URI.encode(url))
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 1000
      debug_http(http)
      if url.match(/^https/)
        debug_msg 'Use SSL'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      req = "Net::HTTP::#{method.to_s.capitalize}".constantize.new(uri.path+params.to_s)
      req.basic_auth user, password if user && password
      [req, http]
    end
    
    #parameters:url-String, method-Symbol||String, params-String, req_body-String, req_headers-Hash, user-String, password:String, debug-Boolean, cookies-Boolean
    def send_request(url: nil, method: nil, params: nil, req_body: nil, req_headers: nil, user: nil, password: nil, debug: @@debug_mode, cookies: false)
      req, http = connect(url: url, method: method, params: params, user: user, password: password, debug: debug)
      req.body = req_body
      req_headers.each { |k, v| req[k] = v } if req_headers
      res = http.request(req)
      res.body
      res_body = begin
                   JSON.parse(res.body)
                 rescue
                   debug_msg 'Can\'t convert response to JSON'
                   res.body
                 end
      cookies ? { body: res_body, cookies: res.response['set-cookie'] } : res_body
    end

    def body_to_str_params(body)
      body.map { |k, v| "#{k.to_s}=#{v.to_s}" }.join('&')
    end

    private

      def enable_debug_mode(enabled)
        if enabled
          @@debug_mode = true
          @log = Logger.new(debug_output)
          @log.level = Logger::DEBUG
        end
      end

      def debug_msg(msg)
        @log.debug(msg) if @log && @@debug_mode
      end
      
      def debug_http(http)
        http.set_debug_output(debug_output) if @@debug_mode
      end

      def debug_output
        STDOUT
      end

  end

end
