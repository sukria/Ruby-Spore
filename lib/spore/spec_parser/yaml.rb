# encoding: utf-8
require 'rubygems'
require 'yaml'
class Spore
  module SpecParser
    class Yaml
      attr_reader :specs
      
      def self.load_file(f)
        YAML.load_file(f)
      end

    end
  end
end
