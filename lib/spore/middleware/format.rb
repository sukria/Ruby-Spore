require 'json'
require 'yaml'
require 'spore/middleware'

class Spore
  class Middleware
    class Format < Spore::Middleware
      
      class UnsupportedFormat < Exception
      end

      def expected_params
        [ :format ]
      end

      def process_response(resp, env)
        if resp.code.to_s.match(/^2\d\d/)
          if self.format.downcase == 'json'
            resp.body = JSON.parse(resp.body)
          elsif self.format.match(/yaml/)
            resp.body = YAML.load(resp.body)
          else
            raise UnsupportedFormat, "don't know how to handle this format '#{self.format}'"
          end
          return resp
        end

        return resp
      end

    end
  end
end
