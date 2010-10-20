require "rubygems"
require "test/unit"
require "spore"


class TestGitHub < Test::Unit::TestCase

  def test_github_search
    github_spec = File.join(File.dirname(__FILE__), 'github.json')
    gh = Spore.new(github_spec)

    r = gh.user_search(:format => 'json', :search => 'sukria')

    puts "resp: #{r.to_yaml}"
  end

end

