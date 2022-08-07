# frozen_string_literal: true

DELTA_LIMIT = 100 # Pretty sure delta.sh has a bug and is only looking at 9 items + self...
POOL_SIZE = 8 # Number of threads to use for parallel processing

desc "Compute delta chain"
task :compute_deltas do
  versions = FileList['raw/*'].map { |f| f.split('/').last.to_i }.sort.map(&:to_s)

  puts "Computing deltas for #{versions.size} versions"

  version_shas = nil
  sha_versions = {}
  cd "raw" do
    sha_list = `sha256sum *`.split("\n").map(&:chomp).map(&:split).map(&:reverse)
    version_shas = sha_list.to_h
    sha_list.each do |(ver, sha)|
      sha_versions[sha] ||= []
      sha_versions[sha] << ver
    end
  end

  work_queue = Queue.new
  thread_pool = (1..POOL_SIZE).map do |i|
    Thread.new do
      thread_id = i
      loop do
        job = work_queue.pop
        break if !job
        target_ver, candidate_vers = *job
        # TODO: Check if the target_ver is in the candidate_vers as a sanity check!

        puts "Computing delta candidates for #{target_ver}"

        target_file = "raw/#{target_ver}"

        candidate_files = candidate_vers.map { |fname| "raw/#{fname}" }.join(' ')

        target_sha = version_shas[target_ver]
        target_ver_i = target_ver.to_i
        zeros = sha_versions[target_sha].reject { |v| v == target_ver || v.to_i > target_ver_i }
        if zeros.length > 0
          best_candidate = zeros.first
          puts "Found identical candidate for #{target_ver}: #{best_candidate}"
          File.write("delta/#{best_candidate}_#{target_ver}.patch", "")
        else
          candidates_raw = `diff --minimal --unified=0 --to-file=#{target_file} #{candidate_files}`
          candidate_diffs = candidates_raw.split(/(?=^--- )/)

          candidate_diffs.map! do |diff|
            ver = diff.match(/^--- raw\/(?<ver>\d+)/)[:ver]
            diff.sub!(/^--- raw\/.*?\n/, "")
            diff.sub!(/^\+\+\+ raw\/.*?\n/, "")
            [ver, diff]
          end

          candidate_diffs.sort_by! { |(ver, diff)| diff.length } # TODO: Do linear search.
          best_ver = candidate_diffs[0].first
          best_diff = candidate_diffs[0].last
          puts "Creating patch for #{target_ver} from: #{best_ver}"
          File.write("delta/#{best_ver}_#{target_ver}.patch", best_diff)
        end
      end
    end
  end

  counter = 0
  versions = versions.reverse
  loop do
    break if counter >= versions.size
    target_ver = versions[counter]

    init_dst = "delta/#{target_ver}"
    # TODO: We can speed this up by getting the list of all existing deltas once and using it to
    # TODO: determine what we don't need to compute.
    if File.exists?(init_dst) || FileList["delta/*_#{target_ver}.patch"].size > 0
      # Found where we left off, so we can bail.
      break
    end

    if counter == versions.size - 1
      cp("raw/#{target_ver}", init_dst)

      counter += 1
      next
    end

    candidate_vers = versions[(counter+1)..(counter+1+DELTA_LIMIT)]
    work_queue.push([target_ver, candidate_vers])

    counter += 1
  end

  puts "Waiting for threads to finish"
  POOL_SIZE.times { work_queue.push(false) }
  thread_pool.each(&:join)
end
