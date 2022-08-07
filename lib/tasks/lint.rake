# frozen_string_literal: true

namespace :lint do
  desc "Run RuboCop"
  task :rubocop do
    sh "rubocop --config=./.rubocop.yml"
  end

  desc "Run Fasterer"
  task :fasterer do
    sh "fasterer"
  end

  desc "Run bundler-audit"
  task :bundle_audit do
    sh "bundle-audit update"
    sh "bundle-audit check"
  end

  desc "Run bundle-leak"
  task :bundle_leak do
    sh "bundle-leak check --update"
  end
end

desc "Run all lint tasks"
task lint: %i[
  lint:rubocop
  lint:fasterer
  lint:bundle_audit
  lint:bundle_leak
]
