# encoding: utf-8
require 'helper'
require 'spore/spec_parser/yaml'
require 'spore/spec_parser/json'
require 'rexml/document'
class TestParser < Test::Unit::TestCase

  def test_yaml_parser
    spec = File.expand_path('../github.yml', __FILE__)
    specs = Spore::SpecParser::Yaml.load_file(spec)
    assert_instance_of Hash, specs
    assert specs.has_key?('name')
  end

  def test_json_parser
    spec = File.expand_path('../github.json', __FILE__)
    specs = Spore::SpecParser::Json.load_file(spec)
    assert_instance_of Hash, specs
    assert specs.has_key?('name')
  end

  def test_custom_parser
    file = File.expand_path('../xml_parser.rb', __FILE__)
    spec = File.expand_path('../github.xml',__FILE__)

    begin
      parser = Spore.load_parser(spec, :require => file, :parser => 'MyCustomParser')
    rescue LoadError
      warn "Can not load XmlSimple gem. Please gem install xml-simple to run this test"
      return
    end
    
    specs = parser.load_file(spec)
    assert_instance_of Hash, specs
    assert specs.has_key?('name')
  end
end
