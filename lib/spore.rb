require 'rubygems'
require 'json'
require 'uri'
require 'net/http'
require 'yaml'

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

  def enable(middleware, args)
    m = middleware.new(args)
    self.middlewares.push(m)
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
        response = m.process_request(env)
        last if response 
      end
 
      if not response

        res = send_http_request(
          env['spore.request_method'],
          env['spore.request_path'],
          env['spore.request_params'],
          env['spore.request_headers'])

        # parse the response and make sure we have expected result
        if expected && (not expected.include?(res.code))
          raise UnexpectedResponse, "response status: '#{res.code}'"
        end

        response = res
      end

      # process response with middlewares in reverse orders
      for m in self.middlewares.reverse
        response = m.process_response(response)
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
      req.add_field(header[:name], header[:value])
    end

    res = Net::HTTP.new(url.host, url.port).start do |http|
      http.request(req)
    end

    return res
  end
end
