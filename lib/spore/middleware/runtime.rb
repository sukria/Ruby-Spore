module Spore
  module Middleware

    class Runtime < Spore::Middleware
      def process_request(env)
        env['spore.middleware.runtime.start'] = Time.now
        return nil
      end

      def process_response(resp)
        elapsed_time = Time.now - env['spore.middleware.runtime.start']
        resp.add_field('X-Spore-Runtime', elapsed_time.to_s)
      end
    end

  end
end
