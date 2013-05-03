$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aktooor/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aktooor"
  s.version     = Aktooor::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Aktooor."
  s.description = "TODO: Description of Aktooor."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.13"
  s.add_dependency "ooorest"
  s.add_dependency "nokogiri"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
