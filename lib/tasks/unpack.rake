# frozen_string_literal: true

desc "Take the deltas, and reconstitute the original series"
# rubocop:disable Metrics/BlockLength
task :unpack do
  system("rm -f unpacked/*")

  delta_files = FileList["delta/**"].map { |f| f.split("/").last }
  delta_files.map! do |fname|
    if /_/.match?(fname) # Patch
      fname.split(".").first.split("_").reverse
    else # Copy
      [fname, nil]
    end
  end

  delta_files.map! { |(target, source)| [Integer(target, 10), source] }
  delta_files.sort_by!(&:first)
  delta_files.map! { |(target, source)| [target.to_s, source] }

  delta_files.each do |(target, source)|
    patch_file = "delta/#{source}_#{target}.patch"
    source_file = "unpacked/#{source}"
    target_file = "unpacked/#{target}"
    if source
      if File.stat(patch_file).size.zero?
        puts "Copying file #{target} from #{source}"
        cp(source_file, target_file)
      else
        puts "Patching #{target} from #{source}"
        sh("patch #{source_file} --output=#{target_file} --input=#{patch_file} 2>&1 | " \
           "grep -v 'missing header'")
      end

      # Debug mechanism to tell us if we've gone astray early:
      exit(1) unless system("diff -u raw/#{target} #{target_file}")
    else
      puts "Copying #{target}"
      sh "cp delta/#{target} #{target_file}"
    end
  end
end
# rubocop:enable Metrics/BlockLength
