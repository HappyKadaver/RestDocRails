$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "rest_doc_rails/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "rest_doc_rails"
  spec.version     = RestDocRails::VERSION
  spec.authors     = ["Dominic Althaus"]
  spec.email       = ["althaus.dominic@gmail.com"]
  spec.homepage    = "https://github.com/HappyKadaver/Rest-Doc-Rails"
  spec.summary     = "Generate a REST API documentation based on your rails code."
  spec.description = "Generate a REST API documentation based on your rails code. This gem uses the rails conventions, routes definitions, models and strong parameters to guess your REST API as good as it can and produces a documentation in different formats."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0.0.rc1"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "sqlite3"
end
