# encoding: utf-8
require 'xmlsimple'
class MyCustomParser
  def self.load_file(spec)
    XmlSimple.xml_in(File.read(spec))
  end
end
