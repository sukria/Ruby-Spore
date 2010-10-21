require 'helper'
require 'spore/middleware/format'

class TestGitHub < Test::Unit::TestCase

  def test_basic_github_search
    github_spec = File.join(File.dirname(__FILE__), 'github.json')
    gh = Spore.new(github_spec)

    r = gh.user_search(:format => 'json', :search => 'sukria')
    assert_kind_of Net::HTTPOK, r
    assert_kind_of String, r.body
  end

  def test_with_format_github_search
    github_spec = File.join(File.dirname(__FILE__), 'github.json')
    gh = Spore.new(github_spec)
    
    gh.enable(Spore::Middleware::Format, :format => 'json')

    assert_equal 1, gh.middlewares.size

    r = gh.user_search(:format => 'json', :search => 'sukria')
    assert_kind_of Net::HTTPOK, r
    assert_kind_of Hash, r.body
    assert_equal 'sukria', r.body['users'][0]['name']
  end

end

