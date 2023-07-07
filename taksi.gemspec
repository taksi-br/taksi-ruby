require_relative 'lib/taksi/version'

Gem::Specification.new do |spec|
  spec.name        = 'taksi'
  spec.version     = Taksi::VERSION
  spec.authors     = ['Israel Trindade']
  spec.email       = ['irto@outlook.com']

  spec.summary     = 'Application framework to build a backend driven UI in ruby'
  spec.description = 'Useful toolset to build a backend over the concept of backend-driven UI (aka. backend for frontend).'

  spec.files         = Dir['CHANGELOG.md', 'LICENSE', 'README.md', 'Rakefile', 'dry-rails.gemspec', 'lib/**/*']
  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['source_code_uri'] = 'https://github.com/taksi-br/taksi-ruby'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/taksi-br/taksi-ruby/issues'

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'

  spec.metadata['rubygems_mfa_required'] = 'true'
end
