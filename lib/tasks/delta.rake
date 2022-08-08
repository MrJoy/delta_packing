# frozen_string_literal: true

DELTA_LIMIT = 100 # Pretty sure delta.sh has a bug and is only looking at 9 items + self...
POOL_SIZE = 8 # Number of threads to use for parallel processing

def sha_data_for_dir(dir)
  version_shas = nil
  sha_versions = {}
  cd(dir) do
    sha_list = `sha256sum *`.split("\n")
    sha_list.map!(&:chomp)
    sha_list.map!(&:split)
    sha_list.map!(&:reverse)
    version_shas = sha_list.to_h
    sha_list.each do |(ver, sha)|
      sha_versions[sha] ||= []
      sha_versions[sha] << ver
    end
  end

  [version_shas, sha_versions]
end

def delta_for?(version)
  # TODO: We can speed this up by getting the list of all existing deltas once and using it to
  # TODO: determine what we don't need to compute.
  File.exist?("delta/#{version}") || FileList["delta/*_#{version}.patch"].size.positive?
end

def record_empty_file!(version)
  puts "Found zero-length file, marking it accordingly: #{version}"
  File.write("delta/#{version}", "")
end

def copy_as_is!(version)
  puts("No good delta for #{version}, copying it as-is")
  cp("raw/#{version}", "delta/#{version}")
end

def null_patch!(from_ver, target_ver)
  puts("Found identical candidate for #{target_ver}: #{from_ver}")
  File.write("delta/#{from_ver}_#{target_ver}.patch", "")
end

def record_patch!(from_ver, target_ver, patch)
  puts("Creating patch for #{target_ver} from: #{from_ver}")
  File.write("delta/#{from_ver}_#{target_ver}.patch", patch)
end

def find_best_delta(candidate_diffs)
  best_ver = candidate_diffs[0].first
  best_diff = candidate_diffs[0].last
  best_diff_size = candidate_diffs[0].last.size
  candidate_diffs.each do |(ver, diff)|
    next unless diff.size <= best_diff_size

    best_ver = ver
    best_diff = diff
    best_diff_size = diff.size
  end

  [best_ver, best_diff]
end

def compute_candidates(target_ver, candidate_vers)
  candidate_files = candidate_vers.map { |fname| "raw/#{fname}" }.join(" ")
  # rubocop:disable EightyFourCodes/CommandLiteralInjection
  candidates_raw = `diff --minimal --unified=0 --to-file=raw/#{target_ver} #{candidate_files}`
  # rubocop:enable EightyFourCodes/CommandLiteralInjection
  candidate_diffs = candidates_raw.split(/(?=^--- )/)

  candidate_diffs.map! do |diff|
    ver = diff.match(%r{^--- raw/(?<ver>\d+)})[:ver]
    diff.sub!(%r{^--- raw/.*?\n}, "")
    diff.sub!(%r{^\+\+\+ raw/.*?\n}, "")
    [ver, diff]
  end

  candidate_diffs
end

def zero_candidate_for(target_ver, version_shas, sha_versions)
  target_sha = version_shas[target_ver]
  target_ver_i = Integer(target_ver, 10)
  zeros =
    sha_versions[target_sha].reject do |v|
      v == target_ver || Integer(v, 10) > target_ver_i
    end

  zeros.first
end

def enqueue_work!(versions, work_queue)
  counter = -1
  versions = versions.reverse
  loop do
    counter += 1
    break if counter >= versions.size

    target_ver = versions[counter]

    break if delta_for?(target_ver)

    if counter == versions.size - 1
      copy_as_is!(target_ver)

      next
    end

    if File.stat("raw/#{target_ver}").size.zero?
      record_empty_file!(target_ver)

      next
    end

    candidate_vers = versions[(counter + 1)..(counter + 1 + DELTA_LIMIT)]
    work_queue.push([target_ver, candidate_vers])
  end
end

def compute_delta!(target_ver, candidate_vers, version_shas, sha_versions)
  # TODO: Check if the target_ver is in the candidate_vers as a sanity check!

  puts("Computing delta candidates for #{target_ver}")

  target_file = "raw/#{target_ver}"

  zero_candidate = zero_candidate_for(target_ver, version_shas, sha_versions)
  if zero_candidate
    null_patch!(zero_candidate, target_ver)
    return
  end

  best_ver, best_diff = find_best_delta(compute_candidates(target_ver, candidate_vers))

  if best_diff.size < File.stat(target_file).size
    record_patch!(best_ver, target_ver, best_diff)
    return
  end

  copy_as_is!(target_ver)
end

desc "Compute delta chain"
# rubocop:disable ThreadSafety/NewThread
task :delta do
  versions = FileList["raw/*"]
  versions.map! { |f| Integer(f.split("/").last, 10) }
  versions.sort!
  versions.map!(&:to_s)

  puts "Computing deltas for #{versions.size} versions"

  version_shas, sha_versions = sha_data_for_dir("raw")

  work_queue = Queue.new
  thread_pool =
    (1..POOL_SIZE).map do
      Thread.new do
        loop do
          job = work_queue.pop
          break unless job

          target_ver, candidate_vers = *job
          compute_delta!(target_ver, candidate_vers, version_shas, sha_versions)
        end
      end
    end

  enqueue_work!(versions, work_queue)

  puts "Waiting for threads to finish"
  POOL_SIZE.times { work_queue.push(false) }
  thread_pool.each(&:join)
end
# rubocop:enable ThreadSafety/NewThread
