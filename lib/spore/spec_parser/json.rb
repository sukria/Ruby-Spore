# encoding: utf-8
require 'rubygems'
require 'json'
class Spore
  module SpecParser
    class Json

      attr_reader :specs
      
      def initialize(file)
        @file = file
        @specs = nil
        load_file
      end

      def self.load_file(f)
        self.new(f).specs
      end

      protected

      def load_file
        File.open(@file,'r') do |file|
          @specs = JSON.parse(file.read)
        end
      end

    end
  end
end
