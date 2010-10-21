Gem::Specification.new do |s|

  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name = 'spore'
  s.version = '0.0.1'
  s.date = '2010-10-20'

  s.summary = 'SPORE implementation for Ruby'
  s.description = "xxx"

  s.authors = ['Alexis Sukrieh']
  s.email = "sukria@sukria.net"

  s.require_paths = %w[lib]

  s.add_dependency('json')

  s.files = %w[
    README
    lib/spore.rb
    lib/spore/middleware.rb
    lib/spore/middleware/runtime.rb
    lib/spore/middleware/format.rb
  ]

  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
