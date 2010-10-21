require 'json'
require 'yaml'
require 'spore/middleware'

# I don't like to do that, but we have to monkeypatch the class of Net::HTTPOK
# because we can't overwrite its body attribute otherwise
module Net
  class HTTPOK
    def body=(value)
      @body = value
    end
  end
end

class Spore
  class Middleware
    class Format < Spore::Middleware
      
      class UnsupportedFormat < Exception
      end

      def expected_params
        [ :format ]
      end

      def process_response(resp, env)

        if self.format.downcase == 'json'
          resp.body = JSON.parse(resp.body)
        elsif self.format.match(/yaml/)
          resp.body = YAML.load(resp.body)
        else
          raise UnsupportedFormat, "don't know how to handle this format '#{self.format}'"
        end

        return resp
      end

    end
  end
end
