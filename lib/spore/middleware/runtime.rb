# encoding: utf-8
class Spore
  class Middleware

    class Runtime < Spore::Middleware
      def process_request(env)
        env['sporex.runtime.start'] = Time.now
        return nil
      end

      def process_response(resp, env)
        elapsed_time = Time.now - env['sporex.runtime.start']
        resp.add_field('X-Spore-Runtime', elapsed_time.to_s)
        return resp
      end
    end

  end
end
