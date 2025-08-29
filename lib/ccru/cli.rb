# frozen_string_literal: true

require_relative "git_diff"
require_relative "linter_runner"

module Ccru
  # Command-line interface for ccru
  class CLI
    def run(argv)
      puts "\n[START] #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}\n\n"
      opts = { base: ENV.fetch("CCRU_BASE", nil), staged: false, files: argv }

      # Check if there are specific files provided
      return run_on_specific_files(opts[:files]) if opts[:files] && opts[:files].any?

      files = Ccru::GitDiff.changed_files(opts[:base], opts[:staged])
      return no_changes if files.empty?

      run_on_files(files)
    end

    private

    include LinterRunner

    def run_on_specific_files(file_paths)
      has_errors = false

      file_paths.each do |path|
        result = process_specific_file(path)
        has_errors = true if result == 1
      end

      return 1 if has_errors

      puts_all_ok
      0
    end

    def process_specific_file(path)
      return 0 unless valid_file?(path)

      file_type = FileTypeDetector.file_type(path)
      meta = { type: :new, lines: nil, file_type: file_type }

      run_linter_file(path, meta)
    end

    def valid_file?(path)
      File.exist?(path) && FileTypeDetector.supported_file?(path)
    end

    def no_changes
      puts_all_ok
      0
    end

    def run_on_files(files)
      has_errors = false

      files.each do |path, meta|
        result = process_file(path, meta)
        has_errors = true if result == 1
      end

      return 1 if has_errors

      puts_all_ok
      0
    end

    def process_file(path, meta)
      return run_linter_file(path, meta) if meta[:type] == :new

      run_linter_filtered(path, meta)
    end

    def puts_all_ok
      puts "ccru: All OK - No violations found\n\n"
    end
  end
end
