require 'rubygems'
require 'yaml'
class Spore
  module SpecParser
    class Yaml
      def self.load_file(f)
        YAML.load_file(f)
      end
    end
  end
end
