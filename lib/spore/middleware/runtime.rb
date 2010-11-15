class Spore
  class Middleware

    class Runtime < Spore::Middleware
      def process_request(env)
        env['sporex.runtime.start'] = Time.now
        return nil
      end

      def process_response(resp, env)
        elapsed_time = Time.now - env['sporex.runtime.start']

        resp.header['X-Spore-Runtime'] = elapsed_time
        return resp
      end
    end

  end
end
