# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in taksi.gemspec.
gemspec

gem 'rake', '>= 12.3.3'

group :test do
  gem 'simplecov', require: false, platforms: :ruby
  gem 'simplecov-cobertura', require: false, platforms: :ruby
end

group :tools do
  gem 'byebug', platforms: :ruby
  gem 'rubocop', '~> 1.48.0'
end
