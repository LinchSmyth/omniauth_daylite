require File.expand_path('../lib/omniauth-daylite/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Linch Smyth"]
  gem.email         = ["linch691995@gmail.com"]
  gem.description   = %q{Unofficial Daylite strategy for OAuth 2}
  gem.summary       = %q{Unofficial Daylite strategy for OAuth 2}
  gem.homepage      = "https://github.com/LinchSmyth/omniauth-daylite"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "omniauth_daylite"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::Daylite::VERSION

  gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.3'
end
