class Spore
  class Middleware
    
    class ExpectedParam < Exception
    end

    def initialize(args)
      for param in self.expected_params
        if not args.has_key?(param)
          raise ExpectedParam, "param '#{param}' is expected"
        end
        
        self.class.send(:attr_accessor, param.to_sym)
        eval "self.#{param} = args[param]"
      end
    end

    def process_request(env)
    end

    
    def process_response(response)
      return response
    end

  end
end
