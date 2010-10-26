# encoding: utf-8
require 'helper'
require 'spore/middleware/runtime'
class TestRuntime < Test::Unit::TestCase

  def test_with_format_github_search
    github_spec = File.join(File.dirname(__FILE__), 'github.json')
    gh = Spore.new(github_spec)
    
    gh.enable(Spore::Middleware::Runtime)
    assert_equal 1, gh.middlewares.size

    r = gh.user_search(:format => 'json', :search => 'sukria')
    assert_kind_of HTTP::Message, r
    assert_equal r.status, 200

    assert_not_nil r.header['X-Spore-Runtime'][0]
    assert r.header['X-Spore-Runtime'][0] > 0.00001
  end

end

