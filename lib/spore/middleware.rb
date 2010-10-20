class Spore
  class Middleware
    
    class ExpectedParam < Exception
    end
    
    # overide this list in your middleware
    # if you need to store some atteributes and make sure
    # they're initialized when the middleware is enabled
    def expected_params
      []
    end

    # you should not need to overrride this one
    def initialize(args)
      for param in self.expected_params
        if not args.has_key?(param)
          raise ExpectedParam, "param '#{param}' is expected"
        end
        
        self.class.send(:attr_accessor, param.to_sym)
        eval "self.#{param} = args[param]"
      end
    end

    # This is where your middleware can handle an incoming request _before_
    # it's executed (the env hash contains anything to build the query)
    # if you want to halt the process of the request, return a Net::HTTP 
    # response object
    # if you just want to alter the env hash, do it and return nil
    def process_request(env)
    end

    # This is where your middleware can alter the response object    
    # Make sure you return _always_ the response object
    def process_response(response, env)
      return response
    end

  end
end
