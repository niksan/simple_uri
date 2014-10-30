require 'logger'
require 'uri'
require 'net/http'
require 'openssl'
require 'active_support/inflector'

module SimpleUri

  class << self

    MODES = { debug: false, autofix: false }

    def connect(url='', method=nil, options={ params: nil, user: nil, password: nil, debug: debug_mode })
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
      if options[:user] && options[:password]
        req.basic_auth options[:user], options[:password]
        debug_msg 'Basic auth'
      end
      [req, http]
    end
    
    def send_request(url=nil, method=:get, options={ params: nil, req_body: nil, req_headers: nil, user: nil, password: nil, debug: debug_mode, autofix: autofix_mode, cookies: false })
      enable_debug_mode(options[:debug])
      enable_autofix_mode(options[:autofix])
      get_params = options[:req_body] ? '?'+prepare_req_body(options[:req_body]).to_s : ''
      options[:params] = method==:post ? nil : get_params
      req, http = connect(url, method, { params: options[:params], user: options[:user], password: options[:password], debug: options[:debug] })
      req.body = prepare_req_body(options[:req_body]) if method == :post
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
    alias req send_request

    private
      
      def prepare_req_body(body)
        (body.is_a?(Hash))? URI.encode_www_form(body) : body
      end
      
      def prepare_url(url)
        if autofix_mode
          m = url.match(/http(s)?:\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.\w{2,5}(:\d+)?\/([1-9.\w])+(.{0})/)
          if m && m[0]==url && url[-1] != '/'
            url += '/'
            debug_msg 'Append \'/\' to url.'
          end
        end
        url
      end

      def enable_debug_mode(enabled)
        if enabled
          debug_mode(true)
          @log = Logger.new(debug_output)
          @log.level = Logger::DEBUG
        end
      end

      def enable_autofix_mode(enabled)
        autofix_mode(true) if enabled
      end

      def debug_msg(msg)
        @log.debug(msg) if @log && debug_mode
      end
      
      def debug_http(http)
        http.set_debug_output(debug_output) if debug_mode
      end

      def debug_output
        STDOUT
      end

      def debug_mode(mode=nil)
        MODES[:debug]=mode unless mode.nil?
        MODES[:debug]
      end

      def autofix_mode(mode=nil)
        MODES[:autofix]=mode unless mode.nil?
        MODES[:autofix]
      end

  end

end
