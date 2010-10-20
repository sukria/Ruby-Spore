# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'rake'

# Set the $LOAD_PATH variable to include all the source files
task :addSourceFiles do
  $LOAD_PATH.push File.dirname(__FILE__) + "/lib/"
end

# Set the $LOAD_PATH variable to include all the test files
task :addTestFiles do
  $LOAD_PATH.push File.dirname(__FILE__) + "/test/"
end

# Target to run the entire test suite
task :test => [:addSourceFiles, :addTestFiles] do
  Dir['test/test*.rb'].each { |test_case|
    require test_case
  }
end

