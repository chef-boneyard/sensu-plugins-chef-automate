lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'sensu-plugins-chef-automate/version'

Gem::Specification.new do |s|
  s.name = "sensu-plugins-chef-automate"
  s.version = SensuPluginsChefAutomate::VERSION
  s.authors = ["Chef Operations"]
  s.email = ["ops@chef.io"]
  s.summary = "Sensu Plugins for Chef Automate"
  s.description = "Checks that are specific to the Chef Automate product"
  s.homepage = "https://github.com/chef/sensu-plugins-chef-automate"
  s.license = "MIT"

  s.files = Dir.glob('{bin,lib}/**/*') + %w(README.md)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|s|features)/})

  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency 'sensu-plugin', '~> 2.0.1'
  s.add_dependency 'rest-client', '~> 2.0.2'

  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-coolline'
  s.add_development_dependency 'rake'
end
