
$:.unshift File.dirname(__FILE__) + "/../vendor/json-1.4.6/lib"

require 'json'
require 'uri'
require 'cgi'
require 'net/http'

class Spore

  attr_accessor :name, :author
  attr_accessor :api_base_url, :api_format, :api_version
  attr_accessor :methods
  attr_accessor :middlewares

  class RequiredParameterExptected < Exception
  end
  class UnexpectedResponse < Exception
  end

  def initialize(spec)
    if not File.exists?(spec)
      raise Exception, "spec file is invalid: #{spec}"
    end

    inititliaze_api_attrs(spec)
    construct_client_class(self.methods)
    self.middlewares = []
  end

  def enable(middleware, args)
    m = middleware.new(self, args)
    self.middlewares.push(m)
  end


private

  def inititliaze_api_attrs(spec)
    file = File.open(spec, 'r')
    json = JSON.parse(file.read)
    file.close
    self.name = json['name']
    self.author = json['author']
    self.api_base_url = json['api_base_url']
    self.api_format = json['api_format']
    self.api_version = json['api_version']
    self.methods = json['methods']
  end

  def construct_client_class(methods)
    for m in methods
      define_method(m)
    end
  end

  def define_method(m)
    name = m['name']
    method = m['method']
    path = m['path']
    params = m['params']
    required = m['required']
    expected = m['expected']
    desc = m['description']

    Spore.send(:define_method, name) do |args| 

      # make sure all mandatory params are sent
      for mandatory in required
        if not args.has_key?(mandatory.to_sym)
          raise RequiredParameterExptected, "parameter `#{mandatory}' expected"
        end
      end
      
      # build the real path (expand named tokens)
      real_path = path
      while m = real_path.match(/:([^:\/\.]+)/)
        if not args.has_key?(m[1].to_sym)
          raise RequiredParameterExptected, "named token `#{m[1]}' expected"
        end
        real_path = real_path.gsub(/:#{m[1]}/, args[m[1].to_sym].to_s)
        args.delete(m[1].to_sym)
      end
      full_path = "#{self.api_base_url}#{real_path}"

      # build the ENV hash
      env = {}
      env['spore.request_method'] = method
      env['spore.request_path'] = full_path
      env['spore.request_params'] = args
      env['spore.request_headers'] = []

      respone = nil

      # puts "BEFORE middlewares got env: #{env.to_json}"

      # call all middlewares
      for m in self.middlewares
        response = m.process_request(env)
        last if response 
      end
 
      puts "AFTER middlewares got env: #{env.to_json}"

      if not response

        res = send_http_request(
          env['spore.request_method'],
          env['spore.request_path'],
          env['spore.request_params'],
          env['spore.request_headers'])

        # parse the response and make sure we have expected result
        if not expected.include?(res.code)
          raise UnexpectedResponse, "response status: '#{res.code}'"
        end
       
        if self.api_format == 'json'
          response = JSON.parse(res.body)
        end
      end

      # puts "BEFORE middlewares got response: #{response.to_json}"

      # process response with middlewares in reverse orders
      for m in self.middlewares.reverse
        response = m.process_response(response)
      end

      # puts "AFTER middlewares got response: #{response.to_json}"
      response
    end
  end

  def send_http_request(method, path, params, headers)
    url = URI.parse(path)

    if method == 'get'
      # XXX GRUICK but how to do a query string GET req properly ???
      # http://stackoverflow.com/questions/1252210/parametrized-get-request-in-ruby
      req = Net::HTTP::Get.new(url.path)
      req.set_form_data(params)
      req = Net::HTTP::Get.new( url.path+ '?' + req.body ) 
    elsif method == 'post'
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data(params)
    elsif method == 'put'
      req = Net::HTTP::Put.new(url.path)
      req.set_form_data(params)
    elsif method == 'delete'
      req = Net::HTTP::Delete.new(url.path)
      req.set_form_data(params)
    end

    for header in headers
      req.add_field(header[:name], header[:value])
    end

    res = Net::HTTP.new(url.host, url.port).start do |http|
      http.request(req)
    end

    return res
  end
end
