require "rubygems"
require "test/unit"
require 'net/http'
require "spore"
require 'spore/middleware/runtime'

class TestRuntime < Test::Unit::TestCase

  def test_with_format_github_search
    github_spec = File.join(File.dirname(__FILE__), 'github.json')
    gh = Spore.new(github_spec)
    
    gh.enable(Spore::Middleware::Runtime)
    assert_equal 1, gh.middlewares.size

    r = gh.user_search(:format => 'json', :search => 'sukria')
    assert_kind_of Net::HTTPOK, r
    assert_not_nil r['X-Spore-Runtime']
    assert r['X-Spore-Runtime'].to_f > 0.00001
  end

end

