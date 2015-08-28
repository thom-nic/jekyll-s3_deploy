# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll_s3/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-s3-deploy"
  spec.version       = JekyllS3::VERSION
  spec.authors       = ["Thom Nichols"]
  spec.email         = ["thom.nichols@voltserver.com"]
  spec.summary       = %q{Deploy your Jekyll site to Amazon S3.}
  spec.description   = %q{This is a Jekyll command that will upload your site to Amazon S3}
  spec.homepage      = "https://github.com/thom_nic/jekyll-s3-deploy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk', '~> 2.1.16'
  spec.add_dependency 'mime-types', '~> 2.6.1'

  spec.add_development_dependency "bundler", ">= 1.6"
  spec.add_development_dependency "rake", ">= 10.0.0"
  spec.add_development_dependency 'rspec', ">= 2.0.0"
end
