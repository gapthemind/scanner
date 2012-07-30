# -*- encoding: utf-8 -*-
require File.expand_path('../lib/scanner/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Diego Alonso"]
  gem.email         = ["diego@gapthemind.net"]
  gem.description   = %q{Simple scanner that returs tokens as symbols}
  gem.summary       = %q{Simple scanner. For the time being, it uses regular expressions to scan tokens}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "scanner"
  gem.require_paths = ["lib"]
  gem.version       = Scanner::VERSION

  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rake"
end
