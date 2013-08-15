$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aktooor/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aktooor"
  s.version     = Aktooor::VERSION
  s.authors     = ["Raphael Valyi - www.akretion.com"]
  s.email       = ["raphael.valyi@akretion.com"]
  s.homepage    = "http://github.com/akretion/aktooor"
  s.summary     = "AktOOOR: the View layer of OpenERP on Rails MVC"
  s.description = "AktOOOR: the View layer of OpenERP on Rails MVC"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "actionpack", ">= 3.1"
  s.add_dependency "simple_form"
  s.add_dependency "ooorest"
  s.add_dependency "nokogiri"
  s.add_dependency "select2-rails"
  s.add_dependency "cocoon"

  s.add_development_dependency "tzinfo" # FIXME: why the hell do we need this for 3.1?
end
