class SporeMiddleware
  class ExpectedParam < Exception
  end

  attr_accessor :spore_client 

  def initialize(object, args)
    for param in self.expected_params
      if not args.has_key?(param)
        raise ExpectedParam, "param '#{param}' is expected"
      end
      
      self.spore_client = object
      object.class.send(:attr_accessor, param.to_sym)
      eval "object.#{param} = args[param]"
    end
  end

  def process_request(env)
  end

  
  def process_response(response)
    return response
  end

end
