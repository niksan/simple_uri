require 'logger'
require 'uri'
require 'net/http'
require 'openssl'
require 'active_support/inflector'

module SimpleUri

  class << self

    @@debug_mode = false

    def connect(url='', method=nil, options={ params: nil, user: nil, password: nil, debug: @@debug_mode })
      enable_debug_mode(options[:debug])
      uri = URI.parse(URI.encode(prepare_url(url)))
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = 1000
      debug_http(http)
      if url.match(/^https/)
        debug_msg 'Use SSL'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      req = "Net::HTTP::#{method.to_s.capitalize}".constantize.new(uri.path+options[:params].to_s)
      req.basic_auth options[:user], options[:password] if options[:user] && options[:password]
      [req, http]
    end
    
    def send_request(url=nil, method=:get, options={ params: nil, req_body: nil, req_headers: nil, user: nil, password: nil, debug: @@debug_mode, cookies: false })
      req, http = connect(url, method, { params: options[:params], user: options[:user], password: options[:password], debug: options[:debug] })
      req.body = prepare_req_body(options[:req_body])
      options[:req_headers].each { |k, v| req[k] = v } if options[:req_headers]
      res = http.request(req)
      res.body
      res_body = begin
                   JSON.parse(res.body)
                 rescue
                   debug_msg 'Can\'t convert response to JSON'
                   res.body
                 end
      options[:cookies] ? { body: res_body, cookies: res.response['set-cookie'] } : res_body
    end

    private
      
      def prepare_req_body(body)
        (body.is_a?(Hash))? body_to_str_params(body) : body
      end

      def body_to_str_params(body)
        body.map { |k, v| "#{k.to_s}=#{v.to_s}" }.join('&')
      end
      
      def prepare_url(url)
        unless url.match(/http(s)?:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.\w{2,5}\/.+/) && url[-1]=='/'
          url += '/'
          debug_msg 'Append \'/\' to url.'
        end
        url
      end

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
