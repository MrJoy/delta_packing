# frozen_string_literal: true

desc "Open Pry"
task :shell do
  # rubocop:disable Lint/Debugger
  require "pry"
  binding.pry
  # rubocop:enable Lint/Debugger
end
