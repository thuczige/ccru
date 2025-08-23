# frozen_string_literal: true

require "set"
require "open3"

require_relative "file_type_detector"

module Ccru
  # Parse git diff to figure changed files and changed line ranges
  class GitDiff
    def initialize(base_ref, only_staged)
      @base_ref = base_ref
      @only_staged = only_staged
    end

    # Returns a Hash: {
    #   "path/to/file.rb" => { type: :new, lines: nil, file_type: :ruby }
    #   "path/script.js" => { type: :new, lines: nil, file_type: :javascript }
    #   "path/mod.rb" => { type: :mod, lines: Set[3,4,10], file_type: :ruby }
    # }
    def self.changed_files(base_ref, only_staged)
      new(base_ref, only_staged).changed_files
    end

    def changed_files
      files = parse_changed_files

      add_changed_lines!(files)

      files
    end

    def parse_changed_files
      files = {}

      each_status_line do |code, path|
        next unless FileTypeDetector.supported_file?(path)

        file_info = build_file_info(code, path)
        files[path] = file_info if file_info
      end

      files
    end

    def build_file_info(code, path)
      case code
      when "A"
        { type: :new, lines: nil, file_type: FileTypeDetector.file_type(path) }
      when "M", "R"
        { type: :mod, lines: Set.new, file_type: FileTypeDetector.file_type(path) }
      end
    end

    def each_status_line
      # Get all supported file types
      extensions = FileTypeDetector::SUPPORTED_EXTENSIONS.keys.map { |ext| "*#{ext}" }
      status_cmd = ["git", "diff", "--name-status", diff_scope, "--", *extensions].flatten

      capture(status_cmd).each_line do |line|
        next if line.strip.empty?

        code, path = parse_status_line(line)
        yield code, path if code && path
      end
    end

    def add_changed_lines!(files)
      mod_paths = files.select { |_, v| v[:type] == :mod }.keys
      return if mod_paths.empty?

      diff_cmd = ["git", "diff", "--unified=0", diff_scope, "--", *mod_paths]
      parse_diff_hunks(capture(diff_cmd), files)
    end

    def parse_diff_hunks(diff_out, files)
      current = nil

      diff_out.each_line do |line|
        if line.start_with?("+++ b/")
          current = line.sub("+++ b/", "").strip
        elsif line =~ /^@@ [^+]*\+(\d+)(?:,(\d+))? @@/
          add_hunk_lines!(files, current, Regexp.last_match(1), Regexp.last_match(2))
        end
      end
    end

    def add_hunk_lines!(files, current, start_str, count_str)
      return unless current && files[current]

      start = start_str.to_i
      count = (count_str || "1").to_i
      files[current][:lines].merge(start...(start + count))
    end

    def diff_scope
      if @only_staged
        ["--staged"]
      else
        [merge_base, "...", "HEAD"].join
      end
    end

    def merge_base
      # Prefer user-specified base or auto-detect main/master
      base = @base_ref
      return base if base && !base.empty?

      # Try origin/main then origin/master then main/master
      candidates = ["origin/main", "origin/master", "main", "master"]

      candidates.each do |ref|
        ok = system({ "LC_ALL" => "C" }, "git", "rev-parse", "--verify", ref, out: File::NULL, err: File::NULL)
        return ref if ok
      end

      # Fallback to HEAD~1 if nothing else
      "HEAD~1"
    end

    def parse_status_line(line)
      # Supports lines like: "A\tpath.rb", "M\tpath.rb", "R100\told.rb\tnew.rb"
      parts = line.strip.split("\t")
      code = parts[0]

      if code && code.start_with?("R") && parts.size == 3
        ["R", parts[2]]
      else
        [code, parts[1]]
      end
    end

    def capture(cmd)
      out, err, status = Open3.capture3(*Array(cmd))

      warn("ccru: failed to run #{Array(cmd).join(" ")}\n#{err}") unless status.success?

      out
    end
  end
end
