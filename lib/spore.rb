require 'rubygems'
require 'json'
require 'uri'
require 'net/http'
require 'yaml'

# we need to be able to build an HTTPResponse object,
# and apparently, there's no way to do that outside of the HTTPResponse class
# WTF?
module Net
  class HTTPResponse
    def body=(value)
      @body = value
    end
  end
end

# SPORE
class Spore

  attr_accessor :name, :author
  attr_accessor :base_url, :format, :version
  attr_accessor :methods
  attr_accessor :middlewares

  class RequiredParameterExptected < Exception
  end
  
  class UnexpectedResponse < Exception
  end

  class UnsupportedSpec < Exception
  end

  class InvalidHeaders < Exception
  end

  def initialize(spec)
    if not File.exists?(spec)
      raise Exception, "spec file is invalid: #{spec}"
    end

    if spec.match(/\.ya?ml/)
      spec = YAML.load_file(spec)
    elsif spec.match(/\.json/)
      file = File.open(spec, 'r')
      spec = JSON.parse(file.read)
      file.close
    else
      raise UnsupportedSpec, "don't know how to parse '#{spec}'"
    end

    inititliaze_api_attrs(spec)
    construct_client_class(self.methods)
    self.middlewares = []
  end

  def enable(middleware, args={})
    m = middleware.new(args)
    self.middlewares.push({
        :condition => Proc.new { true }, 
        :middleware => m
    })
  end

  def enable_if(middleware, args={}, &block)
    m = middleware.new(args)
    self.middlewares.push({
        :condition => block,
        :middleware => m
    })
  end

private

  def inititliaze_api_attrs(spec)
    self.name = spec['name']
    self.author = spec['author']
    self.base_url = spec['base_url'].gsub(/\/$/, '')
    self.format = spec['format']
    self.version = spec['version']
    self.methods = spec['methods']
  end

  def construct_client_class(methods)
    for m in methods.keys
      define_method(m, methods[m])
    end
  end

  def define_method(name, m)
    method = m['method'].downcase
    path = m['path']
    params = m['params']
    required = m['required_params'] || m['required']
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
      full_path = "#{self.base_url}#{real_path}"

      # build the ENV hash
      env = {}
      env['spore.request_method'] = method
      env['spore.request_path'] = full_path
      env['spore.request_params'] = args
      env['spore.request_headers'] = []

      respone = nil

      # call all middlewares
      for m in self.middlewares
        if m[:condition].call(env)
          response = m[:middleware].process_request(env)
          break if response 
        end
      end
 
      # transoform the SPORE response to a valid HTTPResponse object
      if response
        response = to_http(response)
      end

      if not response

        res = send_http_request(
          env['spore.request_method'],
          env['spore.request_path'],
          env['spore.request_params'],
          env['spore.request_headers'])

        # parse the response and make sure we have expected result
        if expected && (not expected.include?(res.code.to_i))
          raise UnexpectedResponse, "response status: '#{res.code}' expected is: #{expected.to_json}"
        end

        response = res
      end

      # process response with middlewares in reverse orders
      for m in self.middlewares.reverse
        if m[:condition].call(env)
          response = m[:middleware].process_response(response, env)
        end
      end

      response
    end
  end

  def send_http_request(method, path, params, headers)
    url = URI.parse(path)

    if method == 'get'
      # XXX GRUICK but how to do a query string GET req properly ???
      # http://stackoverflow.com/questions/1252210/parametrized-get-request-in-ruby
      req = Net::HTTP::Get.new(url.path)
      if not params.empty?
        req.set_form_data(params)
        req = Net::HTTP::Get.new( url.path+ '?' + req.body ) 
      end
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
#      puts "\nadding header '#{header[:name]}' with '#{header[:value]}'"
      req.add_field(header[:name], header[:value])
    end

#    puts "sending request:\n#{req.to_yaml}"
    res = Net::HTTP.new(url.host, url.port).start do |http|
      http.request(req)
    end

    return res
  end

  def to_http(spore_resp)
    return nil if spore_resp.nil?
    return spore_resp if spore_resp.class != Array

    code    = spore_resp[0]
    headers = spore_resp[1]
    body    = spore_resp[2][0]

    if headers.size % 2 != 0
      raise InvalidHeaders, "Odd number of elements in SPORE headers"
    end
  
    r = Net::HTTPResponse.new('1.1', code, '')  
    i = 0
    while i < headers.size
      header = headers[i]
      value  = headers[i+1]
      r.add_field(header, value)
      i += 2
    end

    r.body = body if body

    return r
  end

end
