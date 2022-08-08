# frozen_string_literal: true

desc "Open Pry"
task :shell do
  require "pry"
  binding.pry
end
