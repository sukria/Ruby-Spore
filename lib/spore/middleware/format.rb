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
        return if resp.nil?

        if resp.code.to_s.match(/^2\d\d/)
          
          # empty string is considered nil object
          if resp.body.content.length == 0
            resp.body = nil
            return resp
          end

          # non-empty string are deserialized accordingly
          if self.format.downcase == 'json'
            resp.body = JSON.parse(resp.body.content)
          elsif self.format.match(/yaml/)
            resp.body = YAML.load(resp.body.content)
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
