# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version").chomp

gem "rb-bsdiff", "~> 0.1.1"

# rubocop:disable Bundler/GemVersion
gem "rake"
gem "pry"
# rubocop:enable Bundler/GemVersion

################################################################################
# Dev Tools
################################################################################
group :development do
  # rubocop:disable Bundler/GemVersion
  gem "bundler-audit",                require: false
  gem "bundler-leak",                 require: false

  gem "rubocop", "~> 1.3",            require: false
  gem "rubocop-eightyfourcodes",      require: false
  gem "rubocop-performance",          require: false
  gem "rubocop-rake",                 require: false
  gem "rubocop-rubycw",               require: false
  gem "rubocop-thread_safety",        require: false

  gem "fasterer", require: false
  # rubocop:enable Bundler/GemVersion
end
