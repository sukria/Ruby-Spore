require 'helper'
class TestCollapsing < Test::Unit::TestCase

  test "Use of different api in same project" do
    spore1 = Spore.new(File.expand_path('../github1.yml',__FILE__))
    spore2 = Spore.new(File.expand_path('../github2.yml',__FILE__))
    assert_nothing_raised do
      spore1.list_public_keys(:format => :json)
    end
  end
end

