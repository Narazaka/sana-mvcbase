# coding: utf-8
lib = File.expand_path('../lib', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "sana-mvcbase"
  spec.version       = "0.0.3"
  spec.authors       = ["Narazaka"]
  spec.email         = ["info@narazaka.net"]

  spec.summary       = %q{Ukagaka SHIORI subsystem 'Sana' MVC Helper}
  spec.description   = %q{Ukagaka SHIORI subsystem 'Sana' MVC Helper}
  spec.homepage      = "https://github.com/Narazaka/sana-mvcbase"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.7.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "yard", "~> 0.8.7"
  spec.add_development_dependency "simplecov", "~> 0.11"
  spec.add_development_dependency "codecov", "~> 0.1"
  spec.add_dependency "shioruby", ">= 0.0.3"
  spec.add_dependency "sana", ">= 0.0.4"
end
