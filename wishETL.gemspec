lib = File.expand_path('../lib', __FILE__)
require 'ap'
ap lib
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wishETL/version'

Gem::Specification.new do |spec|
  spec.name                  = "wishETL"
  spec.version               = WishETL::VERSION
  spec.authors               = ["John W Higgins"]
  spec.email                 = ["wishdev@gmail.com"]
  spec.summary               = "ETL tool"
  spec.homepage              = "https://github.com/wishdev/wishETL"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 2.1.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end
