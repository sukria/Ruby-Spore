# encoding: utf-8
require 'helper'
require 'spore/middleware/format'
require 'net/http'

class Spore
  class Middleware
    class FooBar < Spore::Middleware
      def process_request(env)
        [302, ['Location', 'http://www.google.com'], []]
      end
    end
  end
end

class TestEnableIf < Test::Unit::TestCase


  def test_build_github_json
    github_spec = File.join(File.dirname(__FILE__), 'github.json')
    spore = Spore.new(github_spec)
    spore.enable(Spore::Middleware::Format, :format => 'json')

    # user_search is not altered
    r = spore.user_search(:format => 'json', :search => 'sukria')
    assert_equal 'sukria', r.body['users'][0]['name']

    spore.enable_if(Spore::Middleware::FooBar, {}) do |env|
      env['spore.request_path'].match(/\/user\/search/)
    end

    # user_search is altered
    r = spore.user_search(:format => 'json', :search => 'sukria')
    assert_equal 302, r.code
  end

end
