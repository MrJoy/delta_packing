# frozen_string_literal: true

DELTA_LIMIT = 9 # Pretty sure delta.sh has a bug and is only looking at 9 items + self...

desc "Compute delta chain"
task :compute_deltas do
  versions = FileList['raw/*'].map { |f| f.split('/').last.to_i }.sort

  puts "Computing deltas for #{versions.size} versions"

  system "rm -f delta/*" # Using system to avoid noisy output, and to not touch .keep
  system "rm -f candidate/*" # Using system to avoid noisy output, and to not touch .keep

  counter = 0
  loop do
    target_ver = versions[counter]
    if counter == 0
      cp "raw/#{target_ver}", "delta/#{target_ver}"
      counter += 1
      next
    end

    puts "Computing delta candidates for #{target_ver}"
    candidate_vers = versions[0..(counter - 1)]
    candidate_vers = candidate_vers[-DELTA_LIMIT..-1] if candidate_vers.length > DELTA_LIMIT
    candidate_vers.each do |candidate_ver|
      src_file    = "raw/#{candidate_ver}"
      target_file = "raw/#{target_ver}"
      out_file    = "candidate/#{candidate_ver}_#{target_ver}.bsdiff"
      system "bsdiff #{src_file} #{target_file} #{out_file}" # Using system to avoid noisy output
    end

    best_candidate = FileList["candidate/*"].map { |f| [File.stat(f).size, f] }.sort.map(&:last)[0]
    cp best_candidate, "delta/"
    system "rm -f candidate/*" # Using system to avoid noisy output, and to not touch .keep

    counter += 1
    break if counter >= versions.size
  end
end
