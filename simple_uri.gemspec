$:.push File.expand_path("../lib", __FILE__)
require "simple_uri/version"

Gem::Specification.new do |s|
  s.name        = 'simple_uri'
  s.version     = SimpleUri::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.summary     = "To simplify working with url"
  s.description = "To simplify working with url"
  s.authors     = ["Nikulin Aleksander"]
  s.email       = 'nikulinaleksandr@gmail.com'
  s.files       = ['simple_uri.rb', 'simple_uri/version.rb']
  s.homepage    = 'https://github.com/niksan/simple_uri'
end
