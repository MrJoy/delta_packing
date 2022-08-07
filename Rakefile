# frozen_string_literal: true

DELTA_LIMIT = 100 # Pretty sure delta.sh has a bug and is only looking at 9 items + self...
POOL_SIZE = 8 # Number of threads to use for parallel processing

desc "Compute delta chain"
task :compute_deltas do
  versions = FileList['raw/*'].map { |f| f.split('/').last.to_i }.sort.map(&:to_s)

  puts "Computing deltas for #{versions.size} versions"

  system "rm -f candidate_*/*" # Using system to avoid noisy output

  work_queue = Queue.new
  thread_pool = (1..POOL_SIZE).map do |i|
    Thread.new do
      thread_id = i
      mkdir_p "candidate_#{thread_id}"
      loop do
        job = work_queue.pop
        break if !job
        target_ver, candidate_vers = *job

        if File.exists?("delta/#{target_ver}") || FileList["delta/*_#{target_ver}.patch"].size > 0
          # puts "Skipping #{target_ver} because it already has a delta"
          next
        end

        puts "Computing delta candidates for #{target_ver}"

        target_file = "raw/#{target_ver}"
        candidate_vers.each do |candidate_ver|
          src_file    = "raw/#{candidate_ver}"
          out_file    = "candidate_#{thread_id}/#{candidate_ver}_#{target_ver}.patch"
          # N.B. Using system to avoid noisey output
          res = system("diff --minimal --unified=1 #{src_file} #{target_file} | perl -pse 's|^--- #{src_file}|--- source|' | perl -pse 's|^\\+{3} #{target_file}|+++ dest|' > #{out_file}")
          if !res
            STDERR.puts("Failed to compute delta for #{target_ver} -> #{candidate_ver}")
            exit(1)
          end
        end

        candidate_files = FileList["candidate_#{thread_id}/*"]
                          .map { |f| [File.stat(f).size, f] }
                          .sort
                          .map(&:last)
        best_candidate = candidate_files[0]
        cp best_candidate, "delta/"
        system "rm -f candidate_#{thread_id}/*" # Using system to avoid noisy output
      end
    end
  end

  counter = 0
  loop do
    target_ver = versions[counter]
    if counter == 0
      cp "raw/#{target_ver}", "delta/#{target_ver}"
      counter += 1
      next
    end

    candidate_vers = versions[0..(counter - 1)]
    candidate_vers = candidate_vers[-DELTA_LIMIT..-2] if candidate_vers.length > DELTA_LIMIT
    work_queue.push([target_ver, candidate_vers])

    counter += 1
    break if counter >= versions.size
  end

  puts "Waiting for threads to finish"
  POOL_SIZE.times { work_queue.push(false) }
  thread_pool.each(&:join)
  system "rm -rf candidate_*/" # Using system to avoid noisy output
end
