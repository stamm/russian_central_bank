# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'russian_central_bank'
  spec.version       = '0.3.0'
  spec.authors       = ['Ramil Mustafin']
  spec.email         = ['rommel.rmm@gmail.com']
  spec.description   = 'RussianCentralBank extends Money::Bank::VariableExchange and gives you access to the Central Bank of Russia currency exchange rates.'
  spec.summary       = 'Access to Central Bank of Russia currency exchange rates.'
  spec.homepage      = 'http://github.com/rmustafin/russian_central_bank'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '>= 2.0.0'
  spec.add_development_dependency 'webmock', '~> 1.21'

  spec.add_dependency 'money', '>= 5.0'
  spec.add_dependency 'nokogiri', '~> 1.6'
end
